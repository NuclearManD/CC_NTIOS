
prot = "ELEV"

isDisabled = false
redstone.setOutput("left", true)
while true do
    id, msg, dist = rednet.receive(prot)
    print("From "..tostring(id)..": "..msg.." ("..tostring(dist).." blocks away)")
    if msg == "down" and not isDisabled then
        redstone.setOutput("left", false)
        redstone.setOutput("back", true)
        os.sleep(8)
        redstone.setOutput("left", true)
    elseif msg == "up" and not isDisabled then
        redstone.setOutput("left", false)
        redstone.setOutput("back", false)
        os.sleep(8)
        redstone.setOutput("left", true)
    elseif msg == "disable" then
        redstone.setOutput("left", true)
        isDisabled = true
    elseif msg == "enable" then
        isDisabled = false
    end
end