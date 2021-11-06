
local args = { ... }

if #args ~= 1 then
    print("Usage: elevator <up/down>")
end

_id = 11

rednet.send(_id, args[1], "ELEV")