
-- ISGenericMiniDisplayBar
ISGenericMiniDisplayBar = ISPanel:derive("ISGenericMiniDisplayBar")

ISGenericMiniDisplayBar.alwaysBringToTop = true
ISGenericMiniDisplayBar.isEditing = false

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

function ISGenericMiniDisplayBar:onMouseUp(x, y, ...)
    local panel = ISPanel.onMouseUp(self, x, y, ...)
    self.moving = false
    return panel
end

function ISGenericMiniDisplayBar:setOnMouseDoubleClick(target, onmousedblclick, ...)
    local panel = ISPanel.setOnMouseDoubleClick(self, target, onmousedblclick, ...)
    return panel
end

function ISGenericMiniDisplayBar:onMouseUpOutside(x, y, ...)
    local panel = ISPanel.onMouseUpOutside(self, x, y, ...)
    self.moving = false
    return panel
end

local toolTip = nil
function ISGenericMiniDisplayBar:onMouseMoveOutside(dx, dy, ...)
    local panel = ISPanel.onMouseMove(self, dx, dy, ...)
    
    self.showTooltip = false
    
    if self.moving then 
        if MinimalDisplayBars.displayBarPropertiesPanel then
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryX:setText(tostring(self:getX()))
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryY:setText(tostring(self:getY()))
        end
    end
    
    --[[
    if not self.moveWithMouse then return; end
    self.mouseOver = false;

    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx);
            self.parent:setY(self.parent.y + dy);
        else
            self:setX(self.x + dx);
            self:setY(self.y + dy);
            self:bringToTop();
        end
    end
    --]]
end

function ISGenericMiniDisplayBar:onMouseMove(dx, dy, ...)
    local panel = ISPanel.onMouseMove(self, dx, dy, ...)
    
    self.showTooltip = true
    self:bringToTop();
    
    if self.moving then 
        if MinimalDisplayBars.displayBarPropertiesPanel and self == MinimalDisplayBars.displayBarPropertiesPanel.displayBar then
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryX:setText(tostring(self:getX()))
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryY:setText(tostring(self:getY()))
        end
    end
    
    --[[
    if not self.moveWithMouse then return; end
    self.mouseOver = true;

    if self.moving then
        if self.parent then
            self.parent:setX(self.parent.x + dx);
            self.parent:setY(self.parent.y + dy);
        else
            self:setX(self.x + dx);
            self:setY(self.y + dy);
            self:bringToTop();
        end
        --ISMouseDrag.dragView = self;
    end
    --]]
end

--[[
ISGenericMiniDisplayBar.Back_Bad_1 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png");
ISGenericMiniDisplayBar.Back_Bad_2 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_2.png");
ISGenericMiniDisplayBar.Back_Bad_3 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_3.png");
ISGenericMiniDisplayBar.Back_Bad_4 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_4.png");
ISGenericMiniDisplayBar.Back_Good_1 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_1.png");
ISGenericMiniDisplayBar.Back_Good_2 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_2.png");
ISGenericMiniDisplayBar.Back_Good_3 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_3.png");
ISGenericMiniDisplayBar.Back_Good_4 = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png");
ISGenericMiniDisplayBar.Back_Neutral = Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png");
ISGenericMiniDisplayBar.Endurance = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Endurance.png");
ISGenericMiniDisplayBar.Tired = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Tired.png");
ISGenericMiniDisplayBar.Hungry = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Hungry.png");
ISGenericMiniDisplayBar.Panic = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Panic.png");
ISGenericMiniDisplayBar.Sick = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Sick.png");
ISGenericMiniDisplayBar.Bored = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Bored.png");
ISGenericMiniDisplayBar.Unhappy = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Unhappy.png");
ISGenericMiniDisplayBar.Bleeding = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Bleeding.png");
ISGenericMiniDisplayBar.Wet = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Wet.png");
ISGenericMiniDisplayBar.HasACold = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Cold.png");
ISGenericMiniDisplayBar.Angry = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Angry.png");
ISGenericMiniDisplayBar.Stress = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Stressed.png");
ISGenericMiniDisplayBar.Thirst = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Thirsty.png");
ISGenericMiniDisplayBar.Injured = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Injured.png");
ISGenericMiniDisplayBar.Pain = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Pain.png");
ISGenericMiniDisplayBar.HeavyLoad = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_HeavyLoad.png");
ISGenericMiniDisplayBar.Drunk = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Drunk.png");
ISGenericMiniDisplayBar.Dead = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Dead.png");
ISGenericMiniDisplayBar.Zombie = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Zombie.png");
ISGenericMiniDisplayBar.FoodEaten = Texture.getSharedTexture("media/ui/Moodles/Moodle_Icon_Hungry.png");
ISGenericMiniDisplayBar.Hyperthermia = Texture.getSharedTexture("media/ui/weather/Moodle_Icon_TempHot.png");
ISGenericMiniDisplayBar.Hypothermia = Texture.getSharedTexture("media/ui/weather/Moodle_Icon_TempCold.png");
ISGenericMiniDisplayBar.Windchill = Texture.getSharedTexture("media/ui/Moodle_Icon_Windchill.png");
ISGenericMiniDisplayBar.plusRed = Texture.getSharedTexture("media/ui/Moodle_internal_plus_red.png");
ISGenericMiniDisplayBar.minusRed = Texture.getSharedTexture("media/ui/Moodle_internal_minus_red.png");
ISGenericMiniDisplayBar.plusGreen = Texture.getSharedTexture("media/ui/Moodle_internal_plus_green.png");
ISGenericMiniDisplayBar.minusGreen = Texture.getSharedTexture("media/ui/Moodle_internal_minus_green.png");
ISGenericMiniDisplayBar.chevronUp = Texture.getSharedTexture("media/ui/Moodle_chevron_up.png");
ISGenericMiniDisplayBar.chevronUpBorder = Texture.getSharedTexture("media/ui/Moodle_chevron_up_border.png");
ISGenericMiniDisplayBar.chevronDown = Texture.getSharedTexture("media/ui/Moodle_chevron_down.png");
ISGenericMiniDisplayBar.chevronDownBorder = Texture.getSharedTexture("media/ui/Moodle_chevron_down_border.png");
--]]
function ISGenericMiniDisplayBar:getImageBG(isoPlayer, index)
    
    local moodles = isoPlayer:getMoodles()
    local goodBadNeutral = moodles:getGoodBadNeutral(index)
    local moodleLevel = moodles:getMoodleLevel(index)
    
    local switchA = 
    {
        [0] = function()
            return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png")
        end,
        [1] = function()
            
            local switchB = 
            {
                [1] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_1.png")
                end,
                [2] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_2.png")
                end,
                [3] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_3.png")
                end,
                [4] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png")
                end,
            }
            
            local sFunc = switchB[moodleLevel]
            if (sFunc) then
                return sFunc()
            else
                return nil
            end
            
        end,
        [2] = function()
            
            local switchB = 
            {
                [0] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png")
                end,
                [1] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png")
                end,
                [2] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_2.png")
                end,
                [3] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_3.png")
                end,
                [4] = function()
                    return Texture.getSharedTexture("media/ui/Moodles/Moodle_Bkg_Bad_4.png")
                end,
            }
            
            local sFunc = switchB[moodleLevel]
            if (sFunc) then
                return sFunc()
            else
                return nil
            end
            
        end,
    }
    
    local sFunc = switchA[goodBadNeutral]
    
    if (sFunc) then
        return sFunc()
    else
        return nil
    end
    
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
    
    -- Move bar with parent.
    if self.parent and self:isVisible() then
        if not self.parentOldX or not self.parentOldY then
            self.parentOldX = self.parent.x
            self.parentOldY = self.parent.y
        end
        
        local pDX = self.parentOldX - self.parent.x
        local pDY = self.parentOldY - self.parent.y
        if pDX ~= 0 then
            self:setX(self.x - pDX)
            self.parentOldX = self.parent.x
        end
        if pDY ~= 0 then
            self:setY(self.y - pDY)
            self.parentOldY = self.parent.y
        end
        
        if MinimalDisplayBars.displayBarPropertiesPanel and self == MinimalDisplayBars.displayBarPropertiesPanel.displayBar then
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryX:setText(tostring(self:getX()))
            MinimalDisplayBars.displayBarPropertiesPanel.textEntryY:setText(tostring(self:getY()))
        end
    else
        self.parentOldX = nil
        self.parentOldY = nil
    end
    
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
    
    if self.imageShowBack then
        
        -- Automatically picks the way that the bar will show moodle status via an icon/image.
        local switchMoodle = 
        {
            ["hunger"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Hungry" )) )
            end,
            ["thirst"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Thirst" )) )
            end,
            ["endurance"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Endurance" )) )
            end,
            ["fatigue"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Tired" )) )
            end,
            ["boredomlevel"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Bored" )) )
            end,
            ["unhappynesslevel"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Unhappy" )) )
            end,
            ["temperature"] = function()
                self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Hyperthermia" )) ) 
                if not self.texBG then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString( "Hypothermia" )) ) end
            end,
        }
        
        local switchFunc = switchMoodle[self.idName]
        if (switchFunc) then
            switchFunc()
        end
        
        --[[
        if self.idName == "hunger" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Hungry")) )
        elseif self.idName == "thirst" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Thirst")) )
        elseif self.idName == "endurance" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Endurance")) )
        elseif self.idName == "fatigue" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Tired")) )
        elseif self.idName == "boredomlevel" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Bored")) )
        elseif self.idName == "unhappynesslevel" then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Unhappy")) )
        elseif self.idName == "temperature" then 
            self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Hyperthermia")) ) 
            if not self.texBG then self.texBG = self:getImageBG(self.isoPlayer, MoodleType.ToIndex(MoodleType.FromString("Hypothermia")) ) end
        end
        --]]
    end
    
    if self.isVertical then
        
        -- Vertical
        innerWidth = self.innerWidth
        innerHeight = math.floor((self.innerHeight * value) + 0.5)
        border_t = self.borderSizes.t + ((self.height - self.borderSizes.t - self.borderSizes.b) - innerHeight)
        
        -- SHOW IMAGE Vertical
        if self.showImage and self.imageName then
            local w = self.imageSize or 22
            local tex = getTexture(self.imageName)
            --local texBG = getTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png")
            if tex then
                local texH = tex:getHeightOrig()
                local texW = tex:getWidthOrig()
                local texLargeVal = (texH > texW) and texH or texW
                
                local texScale = w / texLargeVal
                
                local h = w
                local x = (-w/2) + self:getWidth()/2
                local y = -w
                
                -- Draw images/textures
                --self:drawTextureScaled(tex, -imgOffset/2, -w, w, w, 1, 1, 1, 1)
                
                -- background texture
                if self.imageShowBack and self.texBG and self.idName ~= "calorie" then
                    self:drawTextureScaled(self.texBG, x, y, w, h, 1, 1, 1, 1)
                end
                
                if self.idName ~= "temperature" and self.idName ~= "calorie" then 
                    if w % 2 == 0 then
                        x = x + 1; 
                        y = y + 1; 
                    else
                        y = y + 1; 
                    end
                end
                
                -- moodle texture
                self:drawTextureScaledAspect(tex, x, y, w, h, 1, 1, 1, 1)
                --self:drawTextureScaledUniform(tex, (-imgOffset/2), -w, texScale, 1, 1, 1, 1)
            end
        end
        
    else 
        
        -- Horizontal
        innerWidth = math.floor((self.innerWidth * value) + 0.5)
        innerHeight = self.innerHeight
        border_t = self.borderSizes.t
        
        -- SHOW IMAGE Horizontal
        if self.showImage and self.imageName then
            local h = self.imageSize or 22
            local tex = getTexture(self.imageName)
            --local texBG = getTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png")
            if tex then
                local texH = tex:getHeightOrig()
                local texW = tex:getWidthOrig()
                local texLargeVal = (texH > texW) and texH or texW
                
                local texScale = h / texLargeVal
                
                local w = h
                local x = -h 
                local y = (-h/2) + self:getHeight()/2
                
                -- Draw images/textures
                --self:drawTextureScaled(tex, -imgOffset/2, -w, w, w, 1, 1, 1, 1)
                
                -- background texture
                if self.imageShowBack and self.texBG and self.idName ~= "calorie" then
                    self:drawTextureScaled(self.texBG, x, y, w, h, 1, 1, 1, 1)
                end
                
                if self.idName ~= "temperature" and self.idName ~= "calorie" then 
                    if h % 2 == 0 then
                        x = x + 1; 
                        y = y + 1; 
                    else
                        y = y + 1; 
                    end
                end
                
                -- moodle texture
                self:drawTextureScaledAspect(tex, x, y, w, h, 1, 1, 1, 1)
                --self:drawTextureScaledUniform(tex, (-imgOffset/2), -w, texScale, 1, 1, 1, 1)
            end
        end
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
            
            if self.isVertical then
                -- Vertical
                innerWidth = self.innerWidth
                innerHeight = 1
                tX = self.borderSizes.l
                tY = self.borderSizes.t + ((self.height - self.borderSizes.t - self.borderSizes.b) - math.floor((self.innerHeight * v) + 0.5))
            else 
                -- Horizontal
                innerWidth = 1
                innerHeight = self.innerHeight
                tX = math.floor((self.innerWidth * v) + 0.5)
                tY = self.borderSizes.t
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
        
        local xOff = 4
        local yOff = self.idName == "menu" and 20 or 4
        local boxWidth = 200
        local boxHeight = FONT_HGT_SMALL * 7
        
        local core = getCore()
        
        -- units
        local unit = ""
        local realValue = string.format("%.4g", self.valueFunction.getValue(self.isoPlayer, true))
        if self.idName == "temperature" then
            if core:isCelsius() or (core.getOptionDisplayAsCelsius and core:getOptionDisplayAsCelsius()) then
                unit = "°C"
            else
                realValue = string.format("%.4g", (self.valueFunction.getValue(self.isoPlayer, true) * 9/5) + 32)
                unit = "°F"
            end
            
        elseif self.idName == "calorie" then
            unit = getText("ContextMenu_MinimalDisplayBars_".. self.idName .."")
        end
        
        local realValue = realValue.. " " ..unit
        
        -- create tooltip text stuff
        local tutorialLeftClick = getText("ContextMenu_MinimalDisplayBars_Tutorial_LeftClick")
        local tutorialRightClick = getText("ContextMenu_MinimalDisplayBars_Tutorial_RightClick")
        local tutorialLeftClickLength = getTextManager():MeasureStringX(UIFont.Small, tutorialLeftClick)
        local tutorialRightClickLength = getTextManager():MeasureStringX(UIFont.Small, tutorialRightClick)
        if tutorialLeftClickLength > boxWidth then
            boxWidth = tutorialLeftClickLength + 20
        end
        if tutorialRightClickLength > boxWidth then
            boxWidth = tutorialRightClickLength + 20
        end
        
        local tooltipTxt
        if self.idName == "menu" then
            tooltipTxt = "" ..getText("ContextMenu_MinimalDisplayBars_".. self.idName .."")
                .."\r\n" ..tutorialLeftClick
                .."\r\n" ..tutorialRightClick
                .."\r\n"
                --.." \r\nx: " ..self.x
                --.." \r\ny: " ..self.y
                boxHeight = boxHeight - FONT_HGT_SMALL
            if self.moving == true then
                tooltipTxt = tooltipTxt
                    .." \r\nx: " ..self.x
                    .." \r\ny: " ..self.y
                boxHeight = boxHeight + FONT_HGT_SMALL*3
            end
            boxHeight = boxHeight - FONT_HGT_SMALL*2
        else
            tooltipTxt = "" ..getText("ContextMenu_MinimalDisplayBars_".. self.idName .."")
                .." \r\nratio: " ..string.format("%.4g", value)
                .." \r\nreal value: " ..realValue
                .."\r\n"
                .."\r\n" ..tutorialLeftClick
                .."\r\n" ..tutorialRightClick
                .."\r\n"
                --.." \r\nx: " ..self.x.. 
                --.." \r\ny: " ..self.y
            if self.moving == true then
                tooltipTxt = tooltipTxt
                    .." \r\nx: " ..self.x
                    .." \r\ny: " ..self.y
                boxHeight = boxHeight + FONT_HGT_SMALL*3
            end
        end
        
        -- make sure tooltips don't go off screen
        if core:getScreenWidth() < self:getX() + boxWidth + xOff then
            xOff = xOff - xOff - boxWidth
        end
        
        if core:getScreenHeight() < self:getY() + boxHeight + yOff then
            yOff = yOff - yOff - boxHeight
        end
        
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectStatic(
            self.borderSizes.l,
            border_t,
            innerWidth,
            innerHeight,
            0.5,
            0,
            0,
            0)
            
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectStatic(
            self.borderSizes.l + xOff,
            self.borderSizes.t + yOff,
            boxWidth,
            boxHeight,
            0.85,
            0,
            0,
            0)
        -- ( x, y, w, h, a, r, g, b)
		self:drawRectBorderStatic(
            self.borderSizes.l + xOff,
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
            self.borderSizes.l + 2 + xOff,
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
    if self.moving == false and not ISGenericMiniDisplayBar.isEditing then
        if self.oldX ~= self.x or self.oldY ~= self.y then
            self.oldX = self.x
            self.oldY = self.y
            MinimalDisplayBars.configTables[self.coopNum][self.idName]["x"] = self.x - self.xOffset
            MinimalDisplayBars.configTables[self.coopNum][self.idName]["y"] = self.y - self.yOffset
            MinimalDisplayBars.io_persistence.store(self.fileSaveLocation, MinimalDisplayBars.MOD_ID, MinimalDisplayBars.configTables[self.coopNum])
        end
    end
    
    -- Force to the top of UI if true.
    if self.alwaysBringToTop == true 
            and (ISGenericMiniDisplayBar.alwaysBringToTop == true 
            or self.idName == "menu") then 
        self:bringToTop() 
    end
    
    return panel
end

function ISGenericMiniDisplayBar:resetToConfigTable(...)
    --local panel = ISPanel.resetToConfigTable(self, ...)
    
    self.x = ( MinimalDisplayBars.configTables[self.coopNum][self.idName]["x"] + self.xOffset )
    self.y = ( MinimalDisplayBars.configTables[self.coopNum][self.idName]["y"] + self.yOffset )
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
    
    --[[
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
    --]]
    
    self.imageName = MinimalDisplayBars.configTables[self.coopNum][self.idName]["imageName"]
    self.imageSize = MinimalDisplayBars.configTables[self.coopNum][self.idName]["imageSize"]
    self.imageShowBack = MinimalDisplayBars.configTables[self.coopNum][self.idName]["imageShowBack"]
    self.showImage = MinimalDisplayBars.configTables[self.coopNum][self.idName]["showImage"]
    
    self.moveBarsTogether = MinimalDisplayBars.configTables[self.coopNum]["moveBarsTogether"]
    
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
    
    --[[
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
    --]]
    
	panel:setVisible(configTable[idName]["isVisible"])
    
    panel.alwaysBringToTop = configTable[idName]["alwaysBringToTop"]
    --panel:setAlwaysOnTop(true)
    
    panel.imageName = configTable[idName]["imageName"]
    panel.imageSize = configTable[idName]["imageSize"]
    panel.imageShowBack = configTable[idName]["imageShowBack"]
    panel.showImage = configTable[idName]["showImage"]
    
    panel.moveBarsTogether = configTable["moveBarsTogether"]
    
    ISGenericMiniDisplayBar.isEditing = false
    
	return panel
end


