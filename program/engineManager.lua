
engine = peripheral.wrap("right")
print(engine)

tankSize = engine.getTankSize()

while true do
    Q = engine.getFluid()
    amount = Q.amount
    name = Q.name

    if amount < 0.6 * tankSize then
        redstone.setOutput("bottom", true)
    elseif amount > 0.9 * tankSize then
        redstone.setOutput("bottom", false)
    end

    write("Engine has "..tostring(amount).."mB ")
    print(string.sub(name, 22))
    
    os.sleep(0.5)
end
