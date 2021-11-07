if not fs.isDir("/disk") then
    print("The turtle does not appear to be in the disk drive.")
    return
end

print("Copying...")

shell.run("cp /ntios/turtlePrograms/* /disk")
