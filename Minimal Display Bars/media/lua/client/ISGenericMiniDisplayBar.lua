
-- ISGenericMiniDisplayBar
ISGenericMiniDisplayBar = ISPanel:derive("ISGenericMiniDisplayBar")

ISGenericMiniDisplayBar.alwaysBringToTop = true


local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)


function ISGenericMiniDisplayBar:setWidth(w, ...)
    local panel = ISPanel.setWidth(self, w, ...)
    self.oldWidth = self.width
    self.innerWidth = (self.width - self.borderSizes.l - self.borderSizes.r)
    return panel
end

function ISGenericMiniDisplayBar:setHeight(h, ...)
    local panel = ISPanel.setHeight(self, h, ...)
    self.oldHeight = self.height
    self.innerHeight = (self.height - self.borderSizes.t - self.borderSizes.b)
    return panel
end

function ISGenericMiniDisplayBar:onMouseDoubleClick(x, y, ...)
    return
end

function ISGenericMiniDisplayBar:onRightMouseDown(x, y, ...)
    local result = ISPanel.onRightMouseDown(self, x, y, ...)
    self.rightMouseDown = true
    return result
end

function ISGenericMiniDisplayBar:onRightMouseUp(dx, dy, ...)
    local panel = ISPanel.onRightMouseUp(self, dx, dy, ...)
    if self.rightMouseDown == true then MinimalDisplayBars.showContextMenu(self, dx, dy) end
	self.rightMouseDown = false
    return panel
end

function ISGenericMiniDisplayBar:onRightMouseUpOutside(x, y, ...)
	local panel = ISPanel.onRightMouseUpOutside(self, x, y, ...)
	self.rightMouseDown = false
	return panel
end

function ISGenericMiniDisplayBar:onMouseDown(x, y, ...)
    local panel = ISPanel.onMouseDown(self, x, y, ...)
    self.oldX = self.x
    self.oldY = self.y
    return panel
end

local toolTip = nil
function ISGenericMiniDisplayBar:onMouseMoveOutside(dx, dy, ...)
    local panel = ISPanel.onMouseMoveOutside(self, dx, dy, ...)
    
    self.showTooltip = false
    
    return panel
end

function ISGenericMiniDisplayBar:onMouseMove(dx, dy, ...)
    local panel = ISPanel.onMouseMove(self, dx, dy, ...)
    
    self.showTooltip = true
    self:bringToTop();
    
    return panel
end

function ISGenericMiniDisplayBar:render(...)
    local panel = ISPanel.render(self, ...)
    
    local innerWidth = 0
    local innerHeight = 0
    local border_t = 0
    
    -- Make sure the bar stays on screen when the window is resized
    --[[if getPlayerScreenWidth(self.playerIndex) < self:getX() + self:getWidth() then
        self:setX(self:getX() - self:getWidth())
    end
    
    if getPlayerScreenHeight(self.playerIndex) < self:getY() + self:getHeight() then
        self:setY(self:getY() - self:getHeight())
    end]]
    
    -- Use the color function of this bar if one exists.
    local value = self.valueFunction.getValue(self.isoPlayer)
    local colorFunc = self.colorFunction
    local color 
    if colorFunc ~= nil and colorFunc.getColor ~= nil then
        color = colorFunc.getColor(self.isoPlayer)
        if color ~= nil and self.useColorFunction == true then self.color = color end
    end
    
    -- If ISOPlayer is dead, or if value is less than or equal to -1, set this bar as not visible.
    if self.isoPlayer:isDead() or value <= -1 then 
        if self:isVisible() then self:setVisible(false) end
    else 
        if not self:isVisible() then self:setVisible(true) end
    end
    
    -- Automatically picks the way that the bar will decrease and increase visually.
    if self.width > self.height then
        -- Horizontal
        innerWidth = math.floor((self.innerWidth * value) + 0.5)
        innerHeight = self.innerHeight
        border_t = self.borderSizes.t
    else 
        -- Vertical
        innerWidth = self.innerWidth
        innerHeight = math.floor((self.innerHeight * value) + 0.5)
        border_t = self.borderSizes.t + ((self.height - self.borderSizes.t - self.borderSizes.b) - innerHeight)
    end
    
    --[[self:drawRectStatic(
        self.borderSizes.l,
        self.borderSizes.t,
        self.innerWidth,
        self.innerHeight,
        self.color.alpha,
        0.3,
        0.05,
        0.05)]]
    
    --=== Draw the bar value visually ===--
    -- ( x, y, w, h, a, r, g, b)
    self:drawRectStatic(
        self.borderSizes.l,
        border_t,
        innerWidth,
        innerHeight,
        self.color.alpha,
        self.color.red,
        self.color.green,
        self.color.blue)
    
    -- Calculate the where the Moodlet Threshold Lines should be drawn using the MoodletThresholdTable.
    if self.showMoodletThresholdLines 
            and self.moodletThresholdTable 
            and type(self.moodletThresholdTable) == "table" then
            
        for k, v in pairs(self.moodletThresholdTable) do
            local tX
            local tY
            local tColor = {red = 0, green = 0, blue = 0, alpha = self.color.alpha}
            
            -- Makes color of threshold lines white or black depending on the values "value" and "v".
            if value < v then 
                tColor.red = 1
                tColor.green = 1
                tColor.blue = 1
            end
            
            if self.width > self.height then
                -- Horizontal
                innerWidth = 1
                innerHeight = self.innerHeight
                tX = math.floor((self.innerWidth * v) + 0.5)
                tY = self.borderSizes.t
            else 
                -- Vertical
                innerWidth = self.innerWidth
                innerHeight = 1
                tX = self.borderSizes.l
                tY = self.borderSizes.t + ((self.height - self.borderSizes.t - self.borderSizes.b) - math.floor((self.innerHeight * v) + 0.5))
            end
            
            -- ( x, y, w, h, a, r, g, b)
            self:drawRectStatic(
                tX,
                tY,
                innerWidth,
                innerHeight,
                self.color.alpha,
                tColor.red,
                tColor.green,
                tColor.blue)
        end
    end
    
    -- Indicate that the user/player is moving or resizing this display bar.
	if self.moving or self.resizing or self.showTooltip then
        
        local yOff = self.idName == "menu" and 20 or 0
        local boxWidth = 150
        local boxHeight = 75
        
        local unit = ""
        local realValue = string.format("%.4g", self.valueFunction.getValue(self.isoPlayer, true))
        if self.idName == "temperature" then
            if getCore():isCelsius() then
                unit = "°C"
            else
                realValue = string.format("%.4g", (self.valueFunction.getValue(self.isoPlayer, true) * 9/5) + 32)
                unit = "°F"
            end
            
        elseif self.idName == "calorie" then
            unit = getText("ContextMenu_MinimalDisplayBars_".. self.idName .."")
        end
        
        local realValue = realValue.. " " ..unit
        
        local tooltipTxt
        if self.idName == "menu" then
            tooltipTxt = "" ..getText("ContextMenu_MinimalDisplayBars_".. self.idName .."").. 
                " \r\nx: " ..self.x.. 
                " \r\ny: " ..self.y
            boxHeight = boxHeight - FONT_HGT_SMALL*2
        else
            tooltipTxt = "" ..getText("ContextMenu_MinimalDisplayBars_".. self.idName .."").. 
                " \r\nratio: " ..string.format("%.4g", value)..
                " \r\nreal value: " ..realValue..
                " \r\nx: " ..self.x.. 
                " \r\ny: " ..self.y
        end
        
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectStatic(
            self.borderSizes.l,
            border_t + yOff,
            innerWidth,
            innerHeight,
            0.5,
            0,
            0,
            0)
            
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectStatic(
            self.borderSizes.l,
            self.borderSizes.t + yOff,
            boxWidth,
            boxHeight,
            0.85,
            0,
            0,
            0)
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectBorderStatic(
            self.borderSizes.l,
            self.borderSizes.t + yOff,
            boxWidth,
            boxHeight,
            0.85,
            1,
            1,
            1)
        
        -- (str, x, y, r, g, b, a, font)
        self:drawText(
            tooltipTxt,
            self.borderSizes.l + 2,
            self.borderSizes.t + 2 + yOff,
            1,
            1,
            1,
            1,
            UIFont.Small)
    end
    
    --[[if self.showTooltip then
        self:bringToTop()
        
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectStatic(
            self.borderSizes.l,
            self.borderSizes.t,
            128,
            128,
            0.85,
            0,
            0,
            0)
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectBorderStatic(
            self.borderSizes.l,
            self.borderSizes.t,
            128,
            128,
            0.85,
            1,
            1,
            1)
        -- (str, x, y, r, g, b, a, font)
        self:drawText(
            ("TEST TOOLTIP"),
            self.borderSizes.l + 5,
            self.borderSizes.t + 3,
            1,
            1,
            1,
            1,
            UIFont.Small)
    end--]]

    -- Text Debugger for stats.
    --[[self:drawText(
        ("Hunger: "..(math.pow(1 - self.isoPlayer:getStats():getHunger(), 2) ).."\r\n"..
            "Thirst: "..(math.pow(1 - self.isoPlayer:getStats():getThirst(), 2) ).."\r\n"..
            "Fatigue: "..(math.pow(1 - self.isoPlayer:getStats():getFatigue(), 2) ).."\r\n"..
            "Endurance: "..((self.isoPlayer:getStats():getEndurance()) ).."\r\n"..
            ""
        ),
        self.borderSizes.l,
        self.borderSizes.t,
        1,
        1,
        1,
        1,
        UIFont.Small)]]

    -- Save to file if the bar was suddenly moved.
    if self.moving == false then
        if self.oldX ~= self.x or self.oldY ~= self.y then
            self.oldX = self.x
            self.oldY = self.y
            MinimalDisplayBars.configTables[self.coopNum][self.idName]["x"] = self.x - self.xOffset
            MinimalDisplayBars.configTables[self.coopNum][self.idName]["y"] = self.y - self.yOffset
            MinimalDisplayBars.io_persistence.store(self.fileSaveLocation, MinimalDisplayBars.MOD_ID, MinimalDisplayBars.configTables[self.coopNum])
        end
    end
    
    -- Force to the top of UI if true.
    if self.alwaysBringToTop == true and (ISGenericMiniDisplayBar.alwaysBringToTop == true or self.idName == "menu") then self:bringToTop() end
    
    return panel
end

function ISGenericMiniDisplayBar:resetToconfigTable(...)
    --local panel = ISPanel.resetToconfigTable(self, ...)
    
    self.x = (MinimalDisplayBars.configTables[self.coopNum][self.idName]["x"] + self.xOffset)
    self.y = (MinimalDisplayBars.configTables[self.coopNum][self.idName]["y"] + self.yOffset)
    self.oldX = self.x
    self.oldY = self.y
    
    self:setWidth(MinimalDisplayBars.configTables[self.coopNum][self.idName]["width"])
    self:setHeight(MinimalDisplayBars.configTables[self.coopNum][self.idName]["height"])
    
    self.oldWidth = self.width
    self.oldHeight = self.height
    
	self.moveWithMouse = MinimalDisplayBars.configTables[self.coopNum][self.idName]["isMovable"]
	self.resizeWithMouse = MinimalDisplayBars.configTables[self.coopNum][self.idName]["isResizable"]
    
	self.borderSizes = {l = MinimalDisplayBars.configTables[self.coopNum][self.idName]["l"], 
                        t = MinimalDisplayBars.configTables[self.coopNum][self.idName]["t"], 
                        r = MinimalDisplayBars.configTables[self.coopNum][self.idName]["r"], 
                        b = MinimalDisplayBars.configTables[self.coopNum][self.idName]["b"]}
	self.innerWidth = (self.width - self.borderSizes.l - self.borderSizes.r)
	self.innerHeight = (self.height - self.borderSizes.t - self.borderSizes.b)
	self.color = MinimalDisplayBars.configTables[self.coopNum][self.idName]["color"]
	self.minimumWidth = (1 + self.borderSizes.l + self.borderSizes.r)
	self.minimumHeight = (1 + self.borderSizes.t + self.borderSizes.b)
    
    self.isVertical = MinimalDisplayBars.configTables[self.coopNum][self.idName]["isVertical"]
    
    self.showMoodletThresholdLines = MinimalDisplayBars.configTables[self.coopNum][self.idName]["showMoodletThresholdLines"]
    --self.moodletThresholdTable = moodletThresholdTable
    
    self.isCompact = MinimalDisplayBars.configTables[self.coopNum][self.idName]["isCompact"]
    
    if self.isVertical then
        if self.width > self.height then
            local oldW = tonumber(self.oldWidth)
            local oldH = tonumber(self.oldHeight)
            self:setWidth(oldH)
            self:setHeight(oldW)
        end
    else
        if self.width < self.height then
            local oldW = tonumber(self.oldWidth)
            local oldH = tonumber(self.oldHeight)
            self:setWidth(oldH)
            self:setHeight(oldW)
        end
    end
    
	self:setVisible(MinimalDisplayBars.configTables[self.coopNum][self.idName]["isVisible"])
    
    self.alwaysBringToTop = MinimalDisplayBars.configTables[self.coopNum][self.idName]["alwaysBringToTop"]
    --self:setAlwaysOnTop(true)
    --return panel
end

function ISGenericMiniDisplayBar:new(
                                idName, fileSaveLocation,  
                                playerIndex, isoPlayer, coopNum, 
                                configTable, xOffset, yOffset, 
                                bChild, 
                                valueFunction, 
                                colorFunction, useColorFunction,
                                moodletThresholdTable)
                                
	local panel = ISPanel:new(  configTable[idName]["x"] + xOffset, 
                                configTable[idName]["y"] + yOffset, 
                                configTable[idName]["width"], 
                                configTable[idName]["height"])
	setmetatable(panel, self)
	self.__index = self
    
    panel.idName = idName
    
    panel.xOffset = xOffset
    panel.yOffset = yOffset
    
    panel.oldX = panel.x
    panel.oldY = panel.y
    panel.oldWidth = panel.width
    panel.oldHeight = panel.height
    
	panel.playerIndex = playerIndex
    panel.isoPlayer = isoPlayer
    panel.coopNum = coopNum
    
    panel.fileSaveLocation = fileSaveLocation
    panel.configTable = configTable
    
	panel.moveWithMouse = configTable[idName]["isMovable"]
	panel.resizeWithMouse = configTable[idName]["isResizable"]
    
	panel.borderSizes = {l = configTable[idName]["l"], 
                        t = configTable[idName]["t"], 
                        r = configTable[idName]["r"], 
                        b = configTable[idName]["b"]}
	panel.innerWidth = (panel.width - panel.borderSizes.l - panel.borderSizes.r)
	panel.innerHeight = (panel.height - panel.borderSizes.t - panel.borderSizes.b)
    
	panel.color = configTable[idName]["color"]
    
	panel.minimumWidth = (1 + panel.borderSizes.l + panel.borderSizes.r)
	panel.minimumHeight = (1 + panel.borderSizes.t + panel.borderSizes.b)
    
	panel.valueFunction = {getValue = valueFunction}
    panel.colorFunction = {getColor = colorFunction}
    panel.useColorFunction = useColorFunction
    panel.isVertical = configTable[idName]["isVertical"]
    
    panel.bChild = bChild
    
    panel.showMoodletThresholdLines = configTable[idName]["showMoodletThresholdLines"]
    panel.moodletThresholdTable = moodletThresholdTable
    
    --panel.lock = false
    
    panel.isCompact = configTable[idName]["isCompact"]
    
    if panel.isVertical then
        if panel.width > panel.height then
            local oldW = tonumber(panel.oldWidth)
            local oldH = tonumber(panel.oldHeight)
            panel:setWidth(oldH)
            panel:setHeight(oldW)
        end
    else
        if panel.width < panel.height then
            local oldW = tonumber(panel.oldWidth)
            local oldH = tonumber(panel.oldHeight)
            panel:setWidth(oldH)
            panel:setHeight(oldW)
        end
    end
    
	panel:setVisible(configTable[idName]["isVisible"])
    
    panel.alwaysBringToTop = configTable[idName]["alwaysBringToTop"]
    --panel:setAlwaysOnTop(true)
    
	return panel
end


