
if not turtle then
    printError("Requires a Turtle")
    return
end


local DEFAULT_PATH = "/ntios/world.map"
local BLOCK_COLORS = {
    ["minecraft:grass_block"] = colors.lime,
    ["minecraft:grass"] = colors.lime,
    ["minecraft:dirt"] = colors.brown,
    ["minecraft:stone"] = colors.lightGray,
    ["minecraft:glass"] = colors.white,
    ["minecraft:obsidian"] = colors.black,
    ["minecraft:blackstone"] = colors.black,
    ["minecraft:cobblestone"] = colors.lightGray,
    ["minecraft:netherrack"] = colors.red,
    ["minecraft:water"] = colors.blue,
    ["minecraft:lava"] = colors.orange,
    ["minecraft:sand"] = colors.yellow,
    ["minecraft:cactus"] = colors.green,
    ["minecraft:snow"] = colors.white,
    ["minecraft:snow_block"] = colors.white,
    ["minecraft:log"] = colors.brown,
    -- Usually I don't want to use gray bc it messes up the UI, but for artificial structures I make an exception.
    ["minecraft:stonebrick"] = colors.gray
}
local x, y, z = gps.locate()
local highestY = y
local startX = x
local startY = y
local startZ = z
local strafeOffset = 0
local orientation = nil
local backtrack = false

local chunks = {}

if not (x and y) then
    print("Unable to get turtle position")
    return
end


local args = { ... }
if #args < 1 then
    print("Usage: mapper <distance> [map=/ntios/world.map]")
    return
end

local distance = tonumber(args[1])
if distance < 1 then
    print("Distance must be positive")
    return
end

local path = DEFAULT_PATH
if #args >= 2 then
    path = shell.resolve(tArgs[2])
    -- Create .map files by default
    if not fs.exists( path ) and not string.find( path, "%." ) then
        path = path .. ".map"
    end
end

if fs.exists(path) and fs.isDir(path) then
    print("Cannot open a directory.")
    return
end

local map = nil
if fs.exists(path) and not fs.isDir(path) then
    local f = fs.open(path, "r")
    map = mapping.deserializeMap(f.readAll())
    f.close()
else
    map = mapping.Map(16)
end

local operation = mining.MiningOperation()

function movementsNeededToReturn()
    local sum = math.abs(startX - x)
    sum = sum + math.abs(highestY - y)
    sum = sum + math.abs(highestY - startY)
    return sum + 2
end

function normalizeOrientation(o)
    o = o % 4
    if o == 0 then
        o = 4
    end
    return o
end

function addToPosition(dx, dy, dz)
    if dx == 0 and dz == 0 then
        y = y + dy
    else
        if orientation == nil then
            -- Compute orientation
            local loc1 = vector.new(x, y, z)
            local loc2 = vector.new(gps.locate())
            local heading = loc2 - loc1
            orientation = (heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3)
            if dx == -1 then
                orientation = orientation + 2
            elseif dz == 1 then
                orientation = orientation + 1
            elseif dz == -1 then
                orientation = orientation + 3
            end
            orientation = normalizeOrientation(orientation)
        end
        x = x + (orientation-2)*(orientation%2)*dx + (orientation-3)*((orientation+1)%2)*dz
        z = z + (orientation-3)*((orientation+1)%2)*dx + (orientation-2)*(orientation%2)*dz
        y = y + dy
        print("p=("..tostring(x)..", "..tostring(y)..", "..tostring(z)..")")
    end
end


function assignDataIntoChunk(data)
    chunk_x = math.floor(x / 16)
    chunk_z = math.floor(z / 16)
    local chunk = {}
    if chunks[chunk_z] then
        if chunks[chunk_z][chunk_x] then
            chunk = chunks[chunk_z][chunk_x]
        else
            chunks[chunk_z][chunk_x] = chunk
        end
    else
        chunks[chunk_z] = {[chunk_x] = chunk}
    end

    chunk[#chunk + 1] = data.name
end

function inspectCurrentPosition()
    while true do
        success, data = turtle.inspectDown()
        if not success then
            if turtle.down() then
                addToPosition(0, -1, 0)
            else
                if turtle.getFuelLevel() == 0 then
                    mining.refuel()
                else
                    return false
                end
            end
        else
            assignDataIntoChunk(data)
            return true
        end
    end
end

function moveForward()
    while true do
        if turtle.forward() then
            addToPosition(1, 0, 0)
            return true
        else
            if turtle.getFuelLevel() == 0 then
                mining.refuel()
            elseif turtle.up() then
                addToPosition(0, 1, 0)
                if y > highestY then
                    highestY = y
                end
            else
                if turtle.getFuelLevel() == 0 then
                    mining.refuel()
                else
                    -- What's above us??
                    success, data = turtle.inspectUp()
                    if success then
                        assignDataIntoChunk(data)
                        print(data.name .. " blocked us from above.")
                    end
                    return false
                end
            end
        end
    end
end

function saveMap()
    for z, tbl in pairs(chunks) do
        for x, blocks in pairs(tbl) do
            local blockColors = {}
            local unknown = 0
            for _, blockname in pairs(blocks) do
                local color = BLOCK_COLORS[blockname]
                if color then
                    blockColors[color] = 1 + (blockColors[color] or 0)
                else
                    unknown = unknown + 1
                    if unknown > (#blocks / 2) then
                        break
                    end
                end
            end
            if unknown < (#blocks / 2) then
                local mostCommonColor = nil
                local highScore = 0
                local secondColor = nil
                local secondScore = 0
                for color, score in pairs(blockColors) do
                    if score > highScore then
                        secondScore = highScore
                        secondColor = mostCommonColor
                        highScore = score
                        mostCommonColor = color
                    elseif score > secondScore then
                        secondScore = score
                        secondColor = color
                    end
                end
                map.setTile(x, z, "surface", mostCommonColor, {secondaryColor = secondColor})
            end
        end
    end


    local f = fs.open(path, "w")
    f.write(map.serialize())
    f.close()
end
    

function mapForDistance(d)
    for i = 1, d do
        inspectCurrentPosition()
        if not moveForward() then
            print("Problem moving to the next block at distance " .. tostring(i - 1))
            print("Returning home with backtracking.")
            backtrack = true
            break
        end
    end
    saveMap()
end

mapForDistance(distance)

mining.refuel()


turtle.turnRight()
if not backtrack then
    if turtle.forward() then
        addToPosition(0, 0, 1)
        strafeOffset = strafeOffset + 1
    else
        -- Don't bother inspecting the same blocks over again
        backtrack = true
    end
end
turtle.turnRight()
orientation = normalizeOrientation(orientation + 2)

for i = 1, distance do
    if not backtrack then
        if z ~= startZ then
            inspectCurrentPosition()
        end
    elseif y < highestY then
        if turtle.up() then
            addToPosition(0, 1, 0)
        end
    end

    if not moveForward() then
        print("Wtot problen kave motore ka domen.  i: " .. tostring(i))
        print("Turning...")
        turtle.turnRight()
        if turtle.forward() then
            addToPosition(0, 0, -1)
            strafeOffset = strafeOffset - 1
        end
        turtle.turnLeft()
        if not moveForward() then
            print("Unable to return home.  Exiting.")
            break
        end
    end
end

for i = y, startY - 1 do
    mining.refuel()
    turtle.up()
end

if strafeOffset > 0 then
    turtle.turnRight()
    for i = 1, strafeOffset do
        turtle.forward()
    end
    turtle.turnRight()
elseif strafeOffset < 0 then
    turtle.turnLeft()
    for i = 1, strafeOffset do
        turtle.forward()
    end
    turtle.turnLeft()
else
    turtle.turnLeft()
    turtle.turnLeft()
end

for i = startY, y - 1 do
    mining.refuel()
    turtle.down()
end


saveMap()
