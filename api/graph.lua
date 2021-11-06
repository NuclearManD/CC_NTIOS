
Graph = {}
Graph.__index = Graph


function Graph.create(canvas, y_scale)
    local self = {}
    setmetatable(self, Graph)

    self._data = {}
    self._sz = 0
    self._off = 0
    self._canvas = canvas
    self._h = canvas.__height - 1
    self._w = canvas.__width
    self._y_scale = self._h / y_scale

    return self
end

function Graph:redraw(is_fg)
    if self._sz == 0 then
        return
    end
    last = nil
    for i = self._sz - 1, 0, -1 do
        val = self._h - self._data[i] * self._y_scale
        val = math.floor(val - 0.5)
        
        if val < self._canvas.__height and val > 0 then
            x = self._sz + 1 - i
            self._canvas:setPixel(x, val, is_fg)
            if last ~= nil then
                step = 1
                if val < last then
                    step = -1
                end
                for j=last, val, step do
                    self._canvas:setPixel(x, j, is_fg)
                end
            end
            last = val
        end
    end
    self._canvas:draw()
end

function Graph:addDataPoint(point)
    self:redraw(false)
    if self._sz == self._w then
        for i = 1, self._sz - 1 do
            self._data[i - 1] = self._data[i]
        end
        self._sz = self._sz - 1
    end
    self._data[self._sz] = point
    self._sz = self._sz + 1
    self:redraw(true)
end

