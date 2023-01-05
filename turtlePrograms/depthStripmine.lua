if not turtle then
    printError("Requires a Turtle")
    return
end

local tArgs = { ... }
if #tArgs ~= 1 then
    print("Will dig a hole down to bedrock,")
    print("Go up 9 blocks,")
    print("then mine a tunnel from there.")
    print("Usage: depthStripmine <length>")
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local length = tonumber(tArgs[1])
if length < 1 then
    print("Tunnel length must be positive")
    return
end

op = mining.MiningOperation()

print("Descending...")
local depth = 0
while op.tryDown() do
    depth = depth + 1
end

for n=1,9 do
    if op.tryUp() then
        depth = depth - 1
    end
end

print("Descended "..tostring(depth).." meters.")

print("Tunnelling...")

op.tunnelUntilFull(length, 3, true)

print("Ascending...")
while depth > 0 do
    if op.tryUp() then
        depth = depth - 1
    end
end

-- Deposit in chest (if present)
op.unload(false)

turtle.turnRight()
turtle.turnRight()

print("Tunnel complete.")
print("Mined " .. (op.collected + op.unloaded) .. " items total.")
