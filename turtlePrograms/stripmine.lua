
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

op = mining.MiningOperation(true)

-- Dig a tunnel
op.tunnelUntilFull(length, 3, true)

-- Deposit in chest (if present)
op.unload(false)

turtle.turnRight()
turtle.turnRight()

print("Tunnel complete.")
print("Mined " .. (op.collected + op.unloaded) .. " items total.")
