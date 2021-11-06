
if #arg == 0 then
    t = peripheral.wrap("current_transformer_2")
else
    t = peripheral.wrap(arg[1])
    if t == nil then
        print("No device found '"..arg[1].."'")
        return
    end
end

local w, h = term.getSize()
local scale = 4100
w = w - 6

canvas = pixel.Canvas.create()
canvas:setSize(w*2, h*3)
g = graph.Graph.create(canvas, scale)

term.setCursorPos(w + 1, 1)
term.write(tostring(scale))
term.setCursorPos(w + 1, h)
term.write("0")

samples = 3

while true do

    -- Collect datapoints and compute the average
    total = 0
    for i=1, samples do
        total = total + t.getAveragePower()
    end
    pwr = total / samples

    -- Add our datapoint and redraw the chart
    g:addDataPoint(pwr)
    term.setCursorPos(w + 1, 1)
    term.write(tostring(scale))
    term.setCursorPos(w + 1, h)
    term.write("0")
end

