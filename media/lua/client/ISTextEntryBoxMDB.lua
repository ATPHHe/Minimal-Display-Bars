require "ISUI/ISUIElement"

ISTextEntryBoxMDB = ISUIElement:derive("ISTextEntryBoxMDB");


--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISTextEntryBoxMDB:initialise()
	ISUIElement.initialise(self);
end

function ISTextEntryBoxMDB:validate()
    local text = self:getInternalText()
    text = text:gsub("[^%d]+", "")
    self:setText(text)
    
    if self.displayBar then
        
        local num = tonumber(text)
        
        local switchOnTextChange = 
        {
            ["x"] = function()
                if num and num < 0 then num = 0 end
                if num == nil then num = 0 end
                self.displayBar:setX(num)
                MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
            end,
            ["y"] = function()
                if num and num < 0 then num = 0 end
                if num == nil then num = 0 end
                self.displayBar:setY(num)
                MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
            end,
            ["height"] = function()
                if num and num < 7 then num = 7 end
                if num == nil then num = 7 end
                self.displayBar:setHeight(num)
                MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
            end,
            ["width"] = function()
                if num and num < 7 then num = 7 end
                if num == nil then num = 7 end
                self.displayBar:setWidth(num)
                MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
            end,
            ["imageSize"] = function()
                if num and num < 1 then num = 1 end
                if num == nil then num = 1 end
                self.displayBar.imageSize = num
                --MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
            end,
        }
        
        local f = switchOnTextChange[self.id]
        if f then 
            f()
        end
        
    end
end

function ISTextEntryBoxMDB:onCommandEntered()
    
end

function ISTextEntryBoxMDB:onTextChange()
    --print(self:getText().."TEXTCHANGE TEXT")
    --print(self:getInternalText().."TEXTCHANGE INTERNALTEXT")
    
    self:validate()
end

function ISTextEntryBoxMDB:ignoreFirstInput()
	self.javaObject:ignoreFirstInput();
end

function ISTextEntryBoxMDB:setOnlyNumbers(onlyNumbers)
    self.javaObject:setOnlyNumbers(onlyNumbers);
end
--************************************************************************--
--** ISPanel:instantiate
--**
--************************************************************************--
function ISTextEntryBoxMDB:instantiate()
	--self:initialise();
	self.javaObject = UITextBox2.new(self.font, self.x, self.y, self.width, self.height, self.title, false);
	self.javaObject:setTable(self);
	self.javaObject:setX(self.x);
	self.javaObject:setY(self.y);
	self.javaObject:setHeight(self.height);
	self.javaObject:setWidth(self.width);
	self.javaObject:setAnchorLeft(self.anchorLeft);
	self.javaObject:setAnchorRight(self.anchorRight);
	self.javaObject:setAnchorTop(self.anchorTop);
	self.javaObject:setAnchorBottom(self.anchorBottom);
	self.javaObject:setEditable(true);
	--self.javaObject:setText(self.title);

end
function ISTextEntryBoxMDB:getText()
	return self.javaObject:getText();
end

function ISTextEntryBoxMDB:setEditable(editable)
    self.javaObject:setEditable(editable);
    if editable then
        self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    else
        self.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    end
end

function ISTextEntryBoxMDB:setSelectable(enable)
	self.javaObject:setSelectable(enable)
end

function ISTextEntryBoxMDB:setMultipleLine(multiple)
    self.javaObject:setMultipleLine(multiple);
end

function ISTextEntryBoxMDB:setMaxLines(max)
    self.javaObject:setMaxLines(max);
end

function ISTextEntryBoxMDB:setClearButton(hasButton)
    self.javaObject:setClearButton(hasButton);
end

function ISTextEntryBoxMDB:setText(str)
    if not str then
        str = "";
    end
	self.javaObject:SetText(str);
	self.title = str;
end

function ISTextEntryBoxMDB:onPressDown()
    self:validate()
end

function ISTextEntryBoxMDB:onPressUp()
    self:validate()
end

function ISTextEntryBoxMDB:focus()
	return self.javaObject:focus();
end

function ISTextEntryBoxMDB:unfocus()
	return self.javaObject:unfocus();
end

function ISTextEntryBoxMDB:getInternalText()
	return self.javaObject:getInternalText();
end

function ISTextEntryBoxMDB:setMasked(b)
	return self.javaObject:setMasked(b);
end

function ISTextEntryBoxMDB:setMaxTextLength(length)
	self.javaObject:setMaxTextLength(length);
end

function ISTextEntryBoxMDB:setForceUpperCase(forceUpperCase)
	self.javaObject:setForceUpperCase(forceUpperCase);
end

--************************************************************************--
--** ISPanel:render
--**
--************************************************************************--
function ISTextEntryBoxMDB:prerender()

	self.fade:setFadeIn(self:isMouseOver() or self.javaObject:isFocused())
	self.fade:update()

	self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	if self.borderColor.a == 1 then
		local rgb = math.min(self.borderColor.r + 0.2 * self.fade:fraction(), 1.0)
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, rgb, rgb, rgb);
	else -- setValid(false)
		local r = math.min(self.borderColor.r + 0.2 * self.fade:fraction(), 1.0)
		self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, r, self.borderColor.g, self.borderColor.b)
	end

    if self:isMouseOver() and self.tooltip then
        local text = self.tooltip;
        if not self.tooltipUI then
            self.tooltipUI = ISToolTip:new()
            self.tooltipUI:setOwner(self)
            self.tooltipUI:setVisible(false)
        end
        if not self.tooltipUI:getIsVisible() then
            if string.contains(self.tooltip, "\n") then
                self.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                self.tooltipUI.maxLineWidth = 300
            end
            self.tooltipUI:addToUIManager()
            self.tooltipUI:setVisible(true)
            self.tooltipUI:setAlwaysOnTop(true)
        end
        self.tooltipUI.description = text
        self.tooltipUI:setX(self:getMouseX() + 23)
        self.tooltipUI:setY(self:getMouseY() + 23)
    else
        if self.tooltipUI and self.tooltipUI:getIsVisible() then
            self.tooltipUI:setVisible(false)
            self.tooltipUI:removeFromUIManager()
        end
    end
end

function ISTextEntryBoxMDB:onMouseMove(dx, dy)
	self.mouseOver = true
end

function ISTextEntryBoxMDB:onMouseMoveOutside(dx, dy)
	self.mouseOver = false
end

function ISTextEntryBoxMDB:onMouseWheel(del)
	self:setYScroll(self:getYScroll() - (del*40))
	return true;
end

function ISTextEntryBoxMDB:clear()
	self.javaObject:clearInput();
end

function ISTextEntryBoxMDB:setHasFrame(hasFrame)
	self.javaObject:setHasFrame(hasFrame)
end

function ISTextEntryBoxMDB:setFrameAlpha(alpha)
	self.javaObject:setFrameAlpha(alpha);
end

function ISTextEntryBoxMDB:getFrameAlpha()
	return self.javaObject:getFrameAlpha();
end

function ISTextEntryBoxMDB:setValid(valid)
	if valid then
		self.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	else
		self.borderColor = {r=0.7, g=0.1, b=0.1, a=0.7}
	end
end

function ISTextEntryBoxMDB:setTooltip(text)
	self.tooltip = text and text:gsub("\\n", "\n") or nil
end

--************************************************************************--
--** ISPanel:new
--**
--************************************************************************--
function ISTextEntryBoxMDB:new(id, title, x, y, width, height, displayBar)
	local o = {}
	--o.data = {}
	o = ISUIElement:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.x = x;
	o.y = y;
    
    o.id = id
	o.title = title;
	o.backgroundColor = {r=0, g=0, b=0, a=0.5};
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.width = width;
	o.height = height;
    o.keeplog = false;
    o.logIndex = 0;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.fade = UITransition.new()
	o.font = UIFont.Small
    o.currentText = title;
    
    o.displayBar = displayBar
    
	return o
end

