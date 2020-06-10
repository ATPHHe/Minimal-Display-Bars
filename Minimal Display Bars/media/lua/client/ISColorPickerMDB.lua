require"ISUI/ISPanelJoypad"

ISColorPickerMDB = ISPanelJoypad:derive("ISColorPickerMDB");

function ISColorPickerMDB:render()
	ISPanelJoypad.render(self)
	for i,color in ipairs(self.colors) do
		local col = (i-1) % self.columns
		local row = math.floor((i-1) / self.columns)
		self:drawRect(self.borderSize + col * self.buttonSize, self.borderSize + row * self.buttonSize, self.buttonSize, self.buttonSize, 1.0, color.r, color.g, color.b)
	end
	for col=1,self.columns do
		self:drawRect(self.borderSize + col * self.buttonSize, self.borderSize, 1, self.buttonSize * self.rows, 1.0, 0.0, 0.0, 0.0)
	end
	for row=1,self.rows do
		self:drawRect(self.borderSize, self.borderSize + row * self.buttonSize, self.buttonSize * self.columns, 1, 1.0, 0.0, 0.0, 0.0)
	end

	local col = (self.index-1) % self.columns
	local row = math.floor((self.index-1) / self.columns)
	self:drawRectBorder(self.borderSize + col * self.buttonSize, self.borderSize + row * self.buttonSize, self.buttonSize + 1, self.buttonSize + 1, 1.0, 1.0, 1.0, 1.0)
end

function ISColorPickerMDB:onMouseDown(x, y)
	self.mouseDown = true
	self:onMouseMove(0, 0)
	return true
end

function ISColorPickerMDB:onMouseDownOutside(x, y)
	self:removeSelf()
    self:close()
	return true
end

function ISColorPickerMDB:onMouseMove(dx, dy)
    if self.otherFct then return true; end
	if not self.mouseDown then return true end
	local x = self:getMouseX()
	local y = self:getMouseY()
	local col = math.floor((x - self.borderSize) / self.buttonSize)
	local row = math.floor((y - self.borderSize) / self.buttonSize)
	if col < 0 then col = 0 end
	if col >= self.columns then col = self.columns - 1 end
	if row < 0 then row = 0 end
	if row >= self.rows then row = self.rows - 1 end
	self.index = col + row * self.columns + 1
	if self.pickedFunc then
		self.pickedFunc(self.pickedTarget, self.colors[self.index], false)
	end
	return true
end

function ISColorPickerMDB:onMouseUp(x, y)
	if self.mouseDown then
		self.mouseDown = false
        if self.otherFct then
		    self:picked2(true)
        else
            self:picked(true)
        end
	end
	return true
end

function ISColorPickerMDB:picked2(hide)
    if hide then
        self:removeSelf()
    end
    local x = self:getMouseX()
    local y = self:getMouseY()
    local col = math.floor((x - self.borderSize) / self.buttonSize)
    local row = math.floor((y - self.borderSize) / self.buttonSize)
    if col < 0 then col = 0 end
    if col >= self.columns then col = self.columns - 1 end
    if row < 0 then row = 0 end
    if row >= self.rows then row = self.rows - 1 end
    self.index = col + row * self.columns + 1
    if self.pickedFunc then
        self.pickedFunc(self.pickedTarget, self.colors[self.index], false)
    end
end

function ISColorPickerMDB:onMouseUpOutside(x, y)
	return self:onMouseUp(x, y)
end

function ISColorPickerMDB:onJoypadDirLeft(joypadData)
	local col = (self.index-1) % self.columns
	if col > 0 then self.index = self.index - 1 else self.index = self.index + self.columns - 1 end
	self:picked(false)
end

function ISColorPickerMDB:onJoypadDirRight(joypadData)
	local col = (self.index-1) % self.columns
	if col < self.columns-1 then self.index = self.index + 1 else self.index = self.index - self.columns + 1 end
	self:picked(false)
end

function ISColorPickerMDB:onJoypadDirUp(joypadData)
	local row = math.floor((self.index-1) / self.columns)
	if row > 0 then self.index = self.index - self.columns else self.index = self.index + self.columns * (self.rows - 1) end
	self:picked(false)
end

function ISColorPickerMDB:onJoypadDirDown(joypadData)
	local row = math.floor((self.index-1) / self.columns)
	if row < self.rows-1 then self.index = self.index + self.columns else self.index = self.index - self.columns * (self.rows - 1) end
	self:picked(false)
end

function ISColorPickerMDB:onJoypadDown(button)
	if button == Joypad.AButton then
		self:picked(true)
	end
	if button == Joypad.BButton then
		self:removeSelf()
	end
end

function ISColorPickerMDB:removeSelf()
	if self.parent then self.parent:removeChild(self) end
	if self.joyfocus then
		self.joyfocus.focus = self.resetFocusTo
	end
end

function ISColorPickerMDB:picked(hide)
	if hide then
		self:removeSelf()
	end
	if self.pickedFunc then
		self.pickedFunc(self.pickedTarget, self.colors[self.index], mouseUp)
	end
end

function ISColorPickerMDB:setInitialColor(initial)
	local d = 10000000
	for index,color in ipairs(self.colors) do
		local dr = math.abs(initial:getR() - color.r)
		local dg = math.abs(initial:getG() - color.g)
		local db = math.abs(initial:getB() - color.b)
		if dr + dg + db < d then
			d = dr + dg + db
			self.index = index
		end
	end
end

function ISColorPickerMDB:new(x, y)
	local buttonSize = 20
	local borderSize = 12
	local columns = 18
	local rows = 12
	local width = columns * buttonSize + borderSize * 2
	local height = rows * buttonSize + borderSize * 2
	local o = ISPanelJoypad:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.borderSize = borderSize
	o.buttonSize = buttonSize
	o.columns = columns
	o.rows = rows
	o.index = 1

	o.colors = {}
	local i = 0
	for red = 0,255,51 do
		for green = 0,255,51 do
			for blue = 0,255,51 do
				local col = i % columns
				local row = math.floor(i / columns)
				if row % 2 == 0 then row = row / 2 else row = math.floor(row / 2) + 6 end
				o.colors[col + row * columns + 1] = { r = red/255, g = green/255, b = blue/255 }
				i = i + 1
			end
		end
	end

	return o
end
