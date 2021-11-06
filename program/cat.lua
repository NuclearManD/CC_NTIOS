
if #arg < 1 then
    print("Prints the contents of a file.")
    print("Usage: cat [file]")
    exit()
end

f = fs.open(arg[1], "r")
print(f.readAll())
f.close()


