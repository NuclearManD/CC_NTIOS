if not fs.isDir("/ntios") then
    print("ERROR STARTING NTIOS: installation dir (/ntios/) does not exist!")
    print("Please install NTIOS.  See https://github.com/NuclearManD/CC_NTIOS")
end

if not fs.exists("/ntios/VERSION") then
    NTIOS_VERSION = "UNKNOWN VERSION"
else
    f = fs.open("/ntios/VERSION", "r")
    NTIOS_VERSION = f.readLine()
end

ACCEPTED_DEVICES = {
    ["arc_furnace"] = "arc_furnace",
    ["capacitor_hv"] = "capacitor",
    ["capacitor_lv"] = "capacitor",
    ["capacitor_mv"] = "capacitor",
    ["mixer"] = "mixer",
    ["engineersdecor:te_small_electrical_furnace"] = "furnace",
    ["thermal:machine_furnace"] = "furnace",
    ["diesel_generator"] = "diesel_generator"
}

-- Update system path to allow use of NTIOS programs
shell.setPath(shell.path()..":/ntios/program")

print("Starting NTIOS version "..NTIOS_VERSION)
print("Loading APIs")

for i,fn in ipairs(fs.list("ntios/api")) do
    os.loadAPI("ntios/api/"..fn)
end

print("Starting devices")

for i,device in ipairs(peripheral.getNames()) do
    if peripheral.getType(device) == "modem" then
        rednet.open(device)
    end

    dev_type = peripheral.getType(device)
    dev_abstracted_type = ACCEPTED_DEVICES[dev_type]
end


print("Starting drivers")

-- What do we want to do here?

if fs.isDir("/ntios/autorun") then
    print("Running startup programs")
    local files = fs.list("/ntios/autorun")
    for _, file in ipairs(files) do
        shell.run("bg /ntios/autorun/"..file)
    end
end
