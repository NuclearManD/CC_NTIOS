local tArgs = { ... }

if #tArgs ~= 2 then
    print("Usage: makeFloor <width> <height>")
    return
end

width = tonumber(tArgs[1])
height = tonumber(tArgs[2])

function autoselect()
    while true do
        for i=2,16 do
            if turtle.getItemCount(i) > 0 then
                turtle.select(i)
                return
            end
        end
        os.pullEvent("turtle_inventory")
    end
end

nextTurn = "right"
for x = 1, width do
    for y = 1, height do
        if turtle.getFuelLevel() < 10 then
            turtle.select(1)
            turtle.refuel(1)
        end
        autoselect()
        turtle.placeDown()
        
        if y ~= height then
            while not turtle.forward() do end
        end
    end
    if x ~= width then
        turtle.turnRight()
        if nextTurn == "right" then
            while not turtle.forward() do end
            nextTurn = "left"
        else
            while not turtle.back() do end
            nextTurn = "right"
        end
        turtle.turnRight()
    end
end