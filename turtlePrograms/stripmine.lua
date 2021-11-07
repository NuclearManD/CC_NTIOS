if not turtle then
    printError("Requires a Turtle")
    return
end

local tArgs = { ... }
if #tArgs ~= 1 then
    print("Usage: tunnel <length>")
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end
local collected = 0
local unloaded = 0

local function collect()
    local bFull = true
    local nTotalItems = 0
    for n=1,16 do
        local nCount = turtle.getItemCount(n)
        if nCount == 0 then
            bFull = false
        end
        nTotalItems = nTotalItems + nCount
    end
    
    if nTotalItems > collected then
        collected = nTotalItems
        if math.fmod(collected + unloaded, 50) == 0 then
            print( "Mined "..(collected + unloaded).." items." )
        end
    end
    
    if bFull then
        print( "No empty slots left." )
        return false
    end
    return true
end

local function tryDig()
    while turtle.detect() do
        if turtle.dig() then
            if not collect() then
                return false
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigUp()
    while turtle.detectUp() do
        if turtle.digUp() then
            if not collect() then
                return false
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigDown()
    while turtle.detectDown() do
        if turtle.digDown() then
            if not collect() then
                return false
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    local function tryRefuel()
        for n = 1, 16 do
            if turtle.getItemCount(n) > 0 then
                turtle.select(n)
                if turtle.refuel(1) then
                    turtle.select(1)
                    return true
                end
            end
        end
        turtle.select(1)
        return false
    end

    if not tryRefuel() then
        print("Add more fuel to continue.")
        while not tryRefuel() do
            os.pullEvent("turtle_inventory")
        end
        print("Resuming Tunnel.")
    end
end

local function tryUp()
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp() then
                return false
            end
        elseif turtle.attackUp() then
            if not collect() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryDown()
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown() then
                return false
            end
        elseif turtle.attackDown() then
            if not collect() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryForward()
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig() then
                return false
            end
        elseif turtle.attack() then
            if not collect() then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function unload( _bKeepOneFuelStack )
    
    print( "Unloading items..." )
    for n=1,16 do
        local nCount = turtle.getItemCount(n)
        if nCount > 0 then
            turtle.select(n)            
            local bDrop = true
            if _bKeepOneFuelStack and turtle.refuel(0) then
                bDrop = false
                _bKeepOneFuelStack = false
            end            
            if bDrop then
                turtle.drop()
                unloaded = unloaded + nCount
            end
        end
    end
    collected = 0
    turtle.select(1)
end

print("Tunnelling...")

distanceTravelled = 0
for n = 1, length do
    turtle.placeDown()
    if not tryDigUp() then
        break
    end
    turtle.turnLeft()
    if not tryDig() then
        turtle.turnRight()
        break
    end
    tryUp()
    if not (tryDig() and tryDigUp()) then
        tryDown()
        turtle.turnRight()
        break
    end
    tryUp() -- Added
    if not tryDig() then
        tryDown()
        tryDown()
        turtle.turnRight()
        break
    end -- Added
    turtle.turnRight()
    turtle.turnRight()
    if not tryDig() then
        tryDown()
        tryDown()
        turtle.turnLeft()
        break
    end
    tryDown()
    if not tryDig() then
        tryDown()
        turtle.turnLeft()
        break
    end
    tryDown() -- Added
    if not tryDig() then
        turtle.turnLeft()
        break
    end -- Added
    turtle.turnLeft()

    if n < length then
        tryDig()
        if not tryForward() then
            print("Aborting Tunnel.")
            break
        end
        distanceTravelled = distanceTravelled + 1
    else
        print("Tunnel complete.")
    end

end


print( "Returning to start..." )

-- Return to where we started
turtle.turnLeft()
turtle.turnLeft()
depth = distanceTravelled
while depth > 0 do
    if turtle.forward() then
        depth = depth - 1
    else
        turtle.dig()
        refuel()
    end
end

-- Deposit in chest (if present)
unload(false)

turtle.turnRight()
turtle.turnRight()

print("Tunnel complete.")
print("Mined " .. (collected + unloaded) .. " items total.")