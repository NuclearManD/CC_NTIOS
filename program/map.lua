
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
    print("  W            Waypoint Tool")
    print("  D            Tile Draw Tool")
    print("  Q            Stop using current tool")
    print("  Arrow Keys   Navigation")
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
    y = centerY + math.floor(h/2) - y
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
    else
        term.write("Tool selected: " .. toolSelected)
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
    local nfp = map.tilesToBitmap(centerX, centerY, layer, mapWidth, mapHeight)
    imaging.drawNfpImage(nfp, 1, 1, colors.black, mapWidth)
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
        end
    else
        if key == keys.w then
            toolSelected = "Waypoint"
        elseif key == keys.d then
            toolSelected = "Tile Drawing"
        elseif key == keys.q then
            toolSelected = "None"
        end
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


function handleMouseUp(x, y)
    if x < w - 1 and y < h - 1 then
        -- Our click is on the map

        local tileX, tileY = clickToTilePos(x, y)
        if toolSelected == "Tile Drawing" then
            map.setTile(tileX, tileY, layer, selectedColor)
            isSaved = false
        end
    elseif x >= w - 1 then
        isSaveMenuOpen = true
    elseif y <= 16 then
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
            local dy = c - y
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
    if evt_type == "mouse_click" and a == 1 then
        handleMouseClick(b, c)
    else
        handleOtherEvent(evt_type, a, b, c)
    end
end


term.setBackgroundColour(colours.black)
term.setTextColour(colours.white)
term.clear()
term.setCursorPos(1,1)
