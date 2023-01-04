
function isGangue(blockInfo)
    if blockInfo.name == "minecraft:stone" then
        return true
    elseif blockInfo.name == "minecraft:gravel" then
        return true
    elseif blockInfo.name == "minecraft:dirt" then
        return true
    elseif blockInfo.name == "minecraft:cobblestone" then
        return true
    elseif blockInfo.name == "minecraft:stonebrick" then
        return true
    elseif blockInfo.name == "minecraft:stone_brick_stairs" then
        return true
    elseif blockInfo.name == "minecraft:grass" then
        return true
    end
    return false
end

local function collect(this)
    local bFull = true
    local nTotalItems = 0
    for n=1,16 do
        local nCount = turtle.getItemCount(n)
        if nCount == 0 then
            bFull = false
        end
        nTotalItems = nTotalItems + nCount
    end
    
    if nTotalItems > this.collected then
        this.collected = nTotalItems
        if this._shouldPrint and math.fmod(this.collected + this.unloaded, 50) == 0 then
            print( "Mined "..(this.collected + this.unloaded).." items." )
        end
    end
    
    if bFull then
        if this._shouldPrint then
            print( "No empty slots left." )
        end
        return false
    end
    return true
end

local function tryDig(this, dontMineGangue)
    if dontMineGangue == nil then
        dontMineGangue = false
    end
    while turtle.detect() do
        _, block = turtle.inspect()
        if dontMineGangue and isGangue(block) then
            return true
        elseif turtle.dig() then
            if not collect(this) then
                return false
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigUp(this, dontMineGangue)
    if dontMineGangue == nil then
        dontMineGangue = false
    end
    while turtle.detectUp() do
        _, block = turtle.inspectUp()
        if dontMineGangue and isGangue(block) then
            return true
        elseif turtle.digUp() then
            if not collect(this) then
                return false
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryDigDown(this, dontMineGangue)
    if dontMineGangue == nil then
        dontMineGangue = false
    end
    while turtle.detectDown() do
        _, block = turtle.inspectDown()
        if dontMineGangue and isGangue(block) then
            return true
        elseif turtle.digDown() then
            if not collect(this) then
                return true
            end
            sleep(0.5)
        else
            return false
        end
    end
    return true
end

local function tryUp(this)
    refuel()
    while not turtle.up() do
        if turtle.detectUp() then
            if not tryDigUp(this) then
                return false
            end
        elseif turtle.attackUp() then
            if not collect(this) then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryDown(this)
    refuel()
    while not turtle.down() do
        if turtle.detectDown() then
            if not tryDigDown(this) then
                return false
            end
        elseif turtle.attackDown() then
            if not collect(this) then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function tryForward(this)
    refuel()
    while not turtle.forward() do
        if turtle.detect() then
            if not tryDig(this) then
                return false
            end
        elseif turtle.attack() then
            if not collect(this) then
                return false
            end
        else
            sleep(0.5)
        end
    end
    return true
end

local function unload(this, _bKeepOneFuelStack)
    if this._shouldPrint then
        print( "Unloading items..." )
    end
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
                this.unloaded = this.unloaded + nCount
            end
        end
    end
    this.collected = 0
    turtle.select(1)
end

-- Will dig a tunnel going forward, then return to the start position.
-- After this the turtle will be rotated 180 degrees.
local function tunnelUntilFull(this, maxLength, height, dontMineGangue)
    height = height or 3
    if dontMineGangue == nil then
        dontMineGangue = true
    end

    if this._shouldPrint then
        print("Tunnelling up to "..tostring(maxLength).." meters...")
    end

    distanceTravelled = 0
    shouldExit = false
    for n = 1, maxLength do
        if dontMineGangue then
            tryDigDown(this, dontMineGangue)
        end
        turtle.turnLeft()
        for h = 1, height do
            if not (this.tryDig(dontMineGangue) and (h == height or tryDigUp(this))) then
                for i = 2, h do
                    tryDown(this)
                end
                shouldExit = true
                break
            end
            if h < height then
                tryUp(this)
            end
        end
        turtle.turnRight()
        if shouldExit then
            break
        end
        if dontMineGangue then
            tryDigUp(this, dontMineGangue)
        end
        turtle.turnRight()
        for h = height, 1, -1 do
            if not tryDig(this, dontMineGangue) then
                for i = 1, h do
                    tryDown(this)
                end
                shouldExit = true
                break
            end
            if h > 1 then
                tryDown(this)
            end
        end
        turtle.turnLeft()
        if shouldExit then
            break
        end

        if n < maxLength then
            tryDig(this)
            if not tryForward(this) then
                if this._shouldPrint then
                    print("Aborting Tunnel.")
                end
                break
            end
            distanceTravelled = distanceTravelled + 1
        elseif this._shouldPrint then
            print("Tunnel complete.")
        end
    end

    if this._shouldPrint then
        print( "Returning to start..." )
    end

    -- Return to where we started
    turtle.turnLeft()
    turtle.turnLeft()
    while distanceTravelled > 0 do
        if turtle.forward() then
            distanceTravelled = distanceTravelled - 1
        else
            turtle.dig()
            refuel()
        end
    end
end

function MiningOperation(shouldPrint)
    if shouldPrint == nil then
        shouldPrint = true
    end

    local this = {}

    this.collected = 0
    this.unloaded = 0
    this._shouldPrint = shouldPrint

    this.collect    = function(...) return collect(this, ...) end
    this.unload     = function(...) return unload(this, ...) end
    this.tryDig     = function(...) return tryDig(this, ...) end
    this.tryDigDown = function(...) return tryDigDown(this, ...) end
    this.tryDigUp   = function(...) return tryDigUp(this, ...) end
    this.tryDown    = function(...) return tryDown(this, ...) end
    this.tryUp      = function(...) return tryUp(this, ...) end
    this.tryForward = function(...) return tryForward(this, ...) end

    this.tunnelUntilFull = function(...) return tunnelUntilFull(this, ...) end

    return this
end

function refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 0 then
        return
    end

    function tryRefuel()
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

