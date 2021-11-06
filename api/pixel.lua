Character = {}
Character.__index = Character

function Character.create()
	local self = {}
	setmetatable(self, Character)
	
	self.textColor = colors.white
	self.backgroundColor = colors.black
	self.pixelMode = false
	self.character = " "
	self.pixel = {{false, false, false},{false, false, false}}
	self.invert = false
	return self
end

function Character:update()
	if self.pixelMode then
		local char = 128
		if not self.pixel[2][3] then
			char = char + (self.pixel[1][1] and 1 or 0)
			char = char + (self.pixel[2][1] and 2 or 0)
			char = char + (self.pixel[1][2] and 4 or 0)
			char = char + (self.pixel[2][2] and 8 or 0)
			char = char + (self.pixel[1][3] and 16 or 0)
			self.invert = false
		else
			char = char + (self.pixel[1][1] and 0 or 1)
			char = char + (self.pixel[2][1] and 0 or 2)
			char = char + (self.pixel[1][2] and 0 or 4)
			char = char + (self.pixel[2][2] and 0 or 8)
			char = char + (self.pixel[1][3] and 0 or 16)
			self.invert = true
		end
		self.character = string.char(char)
	end
end

function Character:draw()
	if not self.invert then
		term.setBackgroundColor(self.backgroundColor)
		term.setTextColor(self.textColor)
	else
		term.setBackgroundColor(self.textColor)
		term.setTextColor(self.backgroundColor)
	end
	term.write(self.character)
end

Canvas = {}
Canvas.__index = Canvas

function Canvas.create()
	local self = {}
	setmetatable (self, {__index=Canvas})
	
	self.x = 1
	self.y = 1
	self.character = {}
	local w, h = term.getSize()
	self:setSize(w, h)
	
	return self
end

function Canvas:setSize(width, height)
	self.__width = width
	self.__height = height
	self.character = {}
	for i=1, self.__width do
		self.character[i] = {}
		for j=1, self.__height do
			self.character[i][j] = Character.create()
		end
	end
end

function Canvas:draw()
	for j=self.y,(self.__height + self.y - 1) do
		term.setCursorPos(self.x, j)
		for i=self.x,(self.__width + self.x - 1) do
			self.character[i][j]:draw()
		end
	end
end

function Canvas:setPixel(x, y, value)
	x = x - 1
	y = y - 1
	local charX = math.floor(x / 2)
	local charY = math.floor(y / 3)
	pixelX = x - charX * 2
	pixelY = y - charY * 3
	charX = charX + 1
	charY = charY + 1
	self.character[charX][charY].pixelMode = true
	self.character[charX][charY].pixel[pixelX + 1][pixelY + 1] = value;
	self.character[charX][charY]:update()
end

function Canvas:setCharacter(x, y, char)
	self.character[charX][charY].invert = false
	self.character[charX][charY].pixelMode = false
	self.character[charX][charY].character = char;
end