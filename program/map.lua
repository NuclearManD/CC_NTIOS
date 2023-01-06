
local DEFAULT_PATH = "/ntios/world.map"

local args = {...}
if #args == 1 and (args[1] == "-h" or args[1] == "--help") then
    print("Usage: map [path]")
    print(" If no path is specified then the default")
    print(" path of '" .. DEFAULT_PATH .. "' will be used.")
    print()
    print("Key controls:")
    print("  CTRL then X  Exit")
    print("  CTRL then S  Save")
    print("  CTRL then P  Print (if a printer is found)")
    print("  G            Go to position (opens a prompt)")
    print("  W            Waypoint Tool")
    print("  D            Tile Draw Tool")
    print("  Q            Stop using current tool")
    print("  Arrow Keys   Navigation (dragging the map also works)")
    print()
    print("Right-clicking on a tile will inspect the tile and")
    print("show the tile coordinates, regardless the selected tool.")
    return
end

local path = DEFAULT_PATH
if #args == 1 then
    path = shell.resolve(tArgs[1])
    -- Create .map files by default
    if not fs.exists( path ) and not string.find( path, "%." ) then
        path = path .. ".map"
    end
end

if fs.exists(path) and fs.isDir(path) then
    print("Cannot edit a directory.")
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

local w,h = term.getSize()
local mapWidth = w - 2
local mapHeight = h - 2
local centerX = 0
local centerY = 0
local layer = "surface"
local isSaveMenuOpen = false
local isSaved = true
local toolSelected = "None"
local shouldExit = false
local selectedColor = colors.lime
local message = nil


function saveMap()
    if not isSaved then
        local f = fs.open(path, "w")
        f.write(map.serialize())
        f.close()
        isSaved = true
    end
end


function clickToTilePos(x, y)
    x = centerX - math.floor(w/2) + x
    y = centerY - math.floor(h/2) + y
    return x, y
end


function confirmExitWithoutSaving()
    local winW = 23
    local winH = 5
    local winX = math.floor((w - winW) / 2)
    local winY = math.floor((h - winH) / 2)
    local confirmWindow = window.create(term.current(), winX, winY, winW, winH)
    confirmWindow.setBackgroundColor(colors.blue)
    confirmWindow.setTextColor(colors.white)
    confirmWindow.clear()
    confirmWindow.setCursorPos(2, 2)
    confirmWindow.write("Exit without saving?")
    confirmWindow.setCursorPos(2, 3)
    confirmWindow.write("Y - Confirm")
    confirmWindow.setCursorPos(2, 4)
    confirmWindow.write("Other keys: Cancel")
    
    _, key = os.pullEvent("key_up")
    render()
    return key == keys.y
end


function promptForText(prompt)
    local winW = w - 2
    local winH = 5
    local winX = math.floor((w - winW) / 2)
    local winY = math.floor((h - winH) / 2)
    local promptWindow = window.create(term.current(), winX, winY, winW, winH)
    promptWindow.setBackgroundColor(colors.blue)
    promptWindow.setTextColor(colors.white)
    promptWindow.clear()
    promptWindow.setCursorPos(2, 2)
    promptWindow.write(prompt)
    promptWindow.setCursorPos(2, 4)
    promptWindow.write("> ")
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.gray)
    result = read()
    render()
    return result
end


function promptForPosition(prompt)
    local winW = w - 2
    local winH = 6
    local winX = math.floor((w - winW) / 2)
    local winY = math.floor((h - winH) / 2)
    local promptWindow = window.create(term.current(), winX, winY, winW, winH)
    promptWindow.setBackgroundColor(colors.blue)
    promptWindow.setTextColor(colors.white)
    promptWindow.clear()
    promptWindow.setCursorPos(2, 2)
    promptWindow.write(prompt)

    promptWindow.setCursorPos(2, 4)
    promptWindow.write("X ")
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.gray)
    local xStr = read()
    local x = tonumber(xStr)
    if x == nil then
        if xStr == "gps" then
            x = xStr
        else
            promptWindow.setCursorPos(2, 4)
            promptWindow.write("Cancelled.  Press enter to continue.")
            promptWindow.setCursorPos(2, 5)
            read()
            render()
            return nil, nil
        end
    end
        
    promptWindow.setCursorPos(2, 5)
    promptWindow.write("Y ")
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.gray)
    local yStr = read()
    local y = tonumber(y)
    if y == nil then
        if yStr == "gps" then
            y = yStr
        else
            promptWindow.setCursorPos(2, 4)
            promptWindow.write("Cancelled.  Press enter to continue.")
            promptWindow.setCursorPos(2, 5)
            read()
            render()
            return nil, nil
        end
    end
    
    if x == "gps" or y == "gps" then
        promptWindow.setCursorPos(2, 4)
        promptWindow.clearLine()
        promptWindow.write("Locating...")

        local gpsX, gpsY, gpsZ = gps.locate()
        if gpsX == nil then
            promptWindow.setCursorPos(2, 4)
            promptWindow.clearLine()
            promptWindow.write("GPS Failed.  Press enter to continue.")
            promptWindow.setCursorPos(2, 5)
            read()
            render()
            return nil, nil
        end

        -- Note that Z and Y are swapped: Minecraft Y is map Z, and Minecraft Z is map Y.
        if x == "gps" then
            x = gpsX
        end
        if y == "gps" then
            y = gpsZ
        end
    end

    -- We don't render here because the caller likely will do so anyway
    return x, y
end


function printMap()
    local printer = peripheral.find( "printer" )
    if not printer then
        message = "No printer found"
        return
    elseif printer.getInkLevel() < 1 then
        message = "Printer out of ink"
        return
    elseif printer.getPaperLevel() < 1 then
        message = "Printer out of paper"
        return
    end

    if printer.newPage() then
        local paperW, paperH = printer.getPageSize()
        printer.setPageTitle(path)
        local text = map.waypointsToText(centerX, centerY, layer, paperW, paperH)
        local lineNumber = 1
        for line in text:gmatch("([^\n]+)") do
            printer.setCursorPos(1, lineNumber)
            printer.write(line)
            lineNumber = lineNumber + 1
        end
        if printer.endPage() then
            message = "Printed"
            return
        end
    end
    message = "Unknown printing error"
end


function renderInterface()
    term.setTextColour(colours.blue)
    term.setBackgroundColour(colours.black)

    term.setCursorPos(1, h-1)
    term.clearLine()
    if isSaved then
        term.write("Opened: " .. path)
    else
        term.write("Modified: " .. path)
    end

    term.setCursorPos(1, h)
    term.clearLine()
    if isSaveMenuOpen then
        term.write("X - eXit  S - Save")
        if peripheral.find("printer") then
            term.write(" P - Print")
        end
    else
        if message then
            term.write(message)
        else
            term.write("Tool selected: " .. toolSelected)
        end
    end

    if toolSelected == "Tile Drawing" then
        -- Tile color picker
        for i=1,16 do
            term.setCursorPos(w-1, i)
            term.setBackgroundColour(2^(i-1))
            term.write("  ")
        end

        term.setCursorPos(w-1, 19)
        term.setBackgroundColour(selectedColor)
        term.setTextColour( colours.white )
        term.write("\127\127")
    else
        for i=1,19 do
            term.setCursorPos(w-1, i)
            term.write("  ")
        end
    end
end


function renderMap()
    local nfp = map.tilesToNfpImage(centerX, centerY, layer, mapWidth, mapHeight)
    local text = map.waypointsToText(centerX, centerY, layer, mapWidth, mapHeight)
    imaging.drawNfpImageWithText(nfp, text, 1, 1, colors.black, mapWidth)
end


function render()
    renderMap()
    renderInterface()
end

function handleKeyUp(key)
    if key == keys.up then
        centerY = centerY + 1
    elseif key == keys.down then
        centerY = centerY - 1
    elseif key == keys.left then
        centerX = centerX - 1
    elseif key == keys.right then
        centerX = centerX + 1
    elseif isSaveMenuOpen then
        if key == keys.x then
            if isSaved == false then
                if confirmExitWithoutSaving() then
                    shouldExit = true
                end
            else
                shouldExit = true
            end
        elseif key == keys.s then
            saveMap()
            isSaveMenuOpen = false
        elseif key == keys.p then
            printMap()
            isSaveMenuOpen = false
        end
    else
        if key == keys.w then
            toolSelected = "Waypoint"
        elseif key == keys.d then
            toolSelected = "Tile Drawing"
        elseif key == keys.q then
            toolSelected = "None"
        elseif key == keys.g then
            x, y = promptForPosition("Coords to go to:")
            if x and y then
                centerX = math.floor(x / map.data.scale)
                centerY = math.floor(y / map.data.scale)
                render()
            end
        end
        message = nil
    end
end

function handleOtherEvent(evt_type, a, b, c)
    if evt_type == "key_up" then
        handleKeyUp(a)
    elseif evt_type == "key" then
        if a == keys.leftCtrl or a == keys.rightCtrl then
            isSaveMenuOpen = not isSaveMenuOpen
            renderInterface()
        end
    end
end


function inspectTile(tileX, tileY)
    local waypoint = map.getWaypointByPosition(tileX, tileY, layer)
    if waypoint then
        message = "'" .. waypoint .. "' at " .. tostring(tileX*16) .. ", " .. tostring(tileY*16)
    else
        message = "Clicked on " .. tostring(tileX*16) .. ", " .. tostring(tileY*16)
    end
end


function handleMouseUp(x, y)
    if x < w - 1 and y < h - 1 then
        -- Our click is on the map

        local tileX, tileY = clickToTilePos(x, y)
        if toolSelected == "Tile Drawing" then
            map.setTile(tileX, tileY, layer, selectedColor)
            isSaved = false
        elseif toolSelected == "Waypoint" then
            local waypointName = promptForText("New waypoint name:")
            if waypointName ~= "" then
                map.setWaypoint(tileX, tileY, layer, waypointName)
                isSaved = false
            end
        else
            inspectTile(tileX, tileY)
        end
    elseif y >= h - 1 then
        isSaveMenuOpen = true
    elseif x >= w - 1 then
        -- Our click is on the right-hand-side bar
        if toolSelected == "Tile Drawing" then
            selectedColor = 2^(y-1)
        end
    end
end


function handleMouseClick(x, y)
    local didDrag = false
    while not shouldExit do
        evt_type, a, b, c = os.pullEvent()
        if evt_type == "mouse_up" and a == 1 then
            if not didDrag then
                handleMouseUp(b, c)
            end
            break
        elseif evt_type == "mouse_drag" and a == 1 then
            local dx = x - b
            local dy = y - c
            x = b
            y = c
            centerX = centerX + dx
            centerY = centerY + dy
            didDrag = true
            renderMap()
        else
            handleOtherEvent(evt_type, a, b, c)
        end
    end
end


while not shouldExit do
    render()
    evt_type, a, b, c = os.pullEvent()
    if evt_type == "mouse_click" then
        if a == 1 then
            handleMouseClick(b, c)
        elseif a == 2 then
            local tileX, tileY = clickToTilePos(b, c)
            inspectTile(tileX, tileY)
        end
    else
        handleOtherEvent(evt_type, a, b, c)
    end
end


term.setBackgroundColour(colours.black)
term.setTextColour(colours.white)
term.clear()
term.setCursorPos(1,1)
