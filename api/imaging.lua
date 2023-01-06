
DEFAULT_WIDTH = 49
DEFAULT_HEIGHT = 18

function colorToChar(value)
    if type(value) == "number" then
        local value = math.floor( math.log(value) / math.log(2) ) + 1
        if value >= 1 and value <= 16 then
            return string.sub( "0123456789abcdef", value, value )
        end
    end
    return " "
end
