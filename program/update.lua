print("This program will update NTIOS to the latest version.")
write("Do you wish to proceed? [Y/n]")

inp = read()
if inp:find("Y", 1, 1) or inp:find("y", 1, 1) then
    shell.run("github clone NuclearManD/CC_NTIOS /ntios")
    fs.move("/ntios/startup.lua", "/startup.lua")
    print("Updated.  Reboot to use the latest version.")
end
