
-- Admittedly, some of this is copied from the NitrogenFingers paint program.

DEFAULT_WIDTH = 49
DEFAULT_HEIGHT = 18

local tColourLookup = {}
for n=1,16 do
    tColourLookup[ string.byte( "0123456789abcdef",n,n ) ] = 2^(n-1)
end

function colorToChar(value)
    if type(value) == "number" then
        local value = math.floor( math.log(value) / math.log(2) ) + 1
        if value >= 1 and value <= 16 then
            return string.sub( "0123456789abcdef", value, value )
        end
    end
    return " "
end

function charToColor(value)
    if type(value) == "string" then
        value = value:byte(0, 0)
    end
    return tColourLookup[value]
end

function drawNfpImage(image, x, y, backgroundColor, w)
    local lines = image:gmatch("([^\n]+)")
    if w == nil then
        w = 0
        for line in lines do
            if #line > w then
                w = #line
            end
        end
    end
    for line in lines do
        if line ~= "" then
            for i = 1, #line do
                local c = line:byte(i,i)
                local pixel = tColourLookup[c]
                if pixel then
                    term.setBackgroundColour( pixel or backgroundColor )
                    term.setCursorPos(x + i - 1, y)
                    term.write(" ")
                elseif backgroundColor then
                    term.setBackgroundColour( backgroundColor )
                    term.setTextColour( colours.grey )
                    term.setCursorPos(x + i - 1, y)
                    term.write("\127")
                end
            end
            if backgroundColor and w > #line then
                for i = #line + 1, w do
                    term.setBackgroundColour( backgroundColor )
                    term.setTextColour( colours.grey )
                    term.setCursorPos(x + i - 1, y)
                    term.write("\127")
                end
            end
        end
        y = y + 1
    end
end

function drawNfpImageWithText(image, text, x, y, backgroundColor, w)
    local lines = image:gmatch("([^\n]+)")
    local textLines = {}
    for line in text:gmatch("([^\n]+)") do
        textLines[#textLines + 1] = line
    end

    if w == nil then
        w = 0
        for line in lines do
            if #line > w then
                w = #line
            end
        end
    end

    local lineNumber = 1
    for line in lines do
        if line ~= "" then
            for i = 1, #line do
                local c = line:byte(i,i)
                local pixel = tColourLookup[c]
                local textChar = " "
                if lineNumber <= #textLines then
                    textChar = textLines[lineNumber]:sub(i, i)
                    if textChar == "" then
                        textChar = " "
                    end
                end
                if pixel or textChar ~= " " then
                    term.setBackgroundColour( pixel or backgroundColor )
                    term.setCursorPos(x + i - 1, y)
                    term.write(textChar)
                elseif backgroundColor then
                    term.setBackgroundColour( backgroundColor )
                    term.setTextColour( colours.grey )
                    term.setCursorPos(x + i - 1, y)
                    term.write("\127")
                end
            end
            if backgroundColor and w > #line then
                for i = #line + 1, w do
                    term.setBackgroundColour( backgroundColor )
                    term.setTextColour( colours.grey )
                    term.setCursorPos(x + i - 1, y)
                    term.write("\127")
                end
            end
        end
        y = y + 1
        lineNumber = lineNumber + 1
    end
end
