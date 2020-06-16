--
-- Created by IntelliJ IDEA.
-- User: RJ
-- Date: 21/09/16
-- Time: 10:19
-- To change this template use File | Settings | File Templates.
--

--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "ISUI/ISPanel"

ISDisplayBarPropertiesPanel = ISPanel:derive("ISDisplayBarPropertiesPanel");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISDisplayBarPropertiesPanel:initialise()
    ISPanel.initialise(self);
    self:create();
end


function ISDisplayBarPropertiesPanel:setVisible(visible)
    --    self.parent:setVisible(visible);
    self.javaObject:setVisible(visible);
end

function ISDisplayBarPropertiesPanel:render()
    local y = 20;
    
    local titleText = 
        getText("ContextMenu_MinimalDisplayBars_Set_HeightWidth") 
            .. " ("
            .. getText("ContextMenu_MinimalDisplayBars_".. self.displayBar.idName .."") 
            ..")"
    self:drawText(
        titleText, 
        self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, titleText) / 2), 
        y, 
        1, 1, 1, 1, UIFont.Medium);
    
    y = y + 30;
    
    self:updateButtons();

end

function ISDisplayBarPropertiesPanel:create()
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    
    local xSpacing = 4
    local padBottom = 10
    
    local y = 10 + 50;
    
    local labelXName = "x" .. ": "
    local labelYName = "y" .. ": "
    local labelWidthName = getText("ContextMenu_MinimalDisplayBars_Width") .. ": "
    if labelWidthName == "ContextMenu_MinimalDisplayBars_Width: " then 
        labelWidthName = "Width: " end
    local labelHeightName = getText("ContextMenu_MinimalDisplayBars_Height") .. ": "
    if labelHeightName == "ContextMenu_MinimalDisplayBars_Height: " then 
        labelHeightName = "Width: " end
    local labelImageSizeName = getText("ContextMenu_MinimalDisplayBars_IconSize") .. ": "
    if labelImageSizeName == "ContextMenu_MinimalDisplayBars_IconSize: " then 
        labelImageSizeName = "Height: " end
    local labelSetVerticalName = getText("ContextMenu_MinimalDisplayBars_Set_Vertical")
    if labelSetVerticalName == "ContextMenu_MinimalDisplayBars_Set_Vertical" then 
        labelSetVerticalName = "Set Vertical" end
    
    ------------------------------------
    -- X
    self.textEntryX = 
        ISTextEntryBoxMDB:new(
            "x", 
            tostring(self.displayBar:getX()), 
            self:getWidth()/2 + 32, 
            y, 
            self.width - 20, 
            FONT_HGT_SMALL + 4, 
            self.displayBar)
    self.textEntryX:initialise();
    self.textEntryX:instantiate();
    --self.textEntryX:setTooltip("x");
    self.textEntryX:setOnlyNumbers(true);
    self:addChild(self.textEntryX);
    
    self.labelX = 
        ISLabel:new(
            self.textEntryX:getX(), 
            y, 
            FONT_HGT_SMALL + 4, 
            "", 
            1, 
            1, 
            1, 
            1, 
            UIFont.Small, 
            true)
    self.labelX:setTranslation( labelXName )
    self.labelX:setX(self.labelX:getX() - self.labelX:getWidth())
    self.labelX:initialise();
    self.labelX:instantiate();
    self:addChild(self.labelX);
    y = y + self.textEntryX:getHeight();
    ------------------------------------
    -- Y
    self.textEntryY = 
        ISTextEntryBoxMDB:new(
            "y", 
            tostring(self.displayBar:getY()), 
            self:getWidth()/2 + 32, 
            y, 
            self.width - 20, 
            FONT_HGT_SMALL + 4, 
            self.displayBar)
    self.textEntryY:initialise();
    self.textEntryY:instantiate();
    --self.textEntryY:setTooltip("y");
    self.textEntryY:setOnlyNumbers(true);
    self:addChild(self.textEntryY);
    
    self.labelY = 
        ISLabel:new(
            self.textEntryY:getX(), 
            y, 
            FONT_HGT_SMALL + 4, 
            "", 
            1, 
            1, 
            1, 
            1, 
            UIFont.Small, 
            true)
    self.labelY:setTranslation( labelYName )
    self.labelY:setX(self.labelY:getX() - self.labelY:getWidth())
    self.labelY:initialise();
    self.labelY:instantiate();
    self:addChild(self.labelY);
    y = y + self.textEntryY:getHeight() + 10;
    ------------------------------------
    -- Width
    self.textEntryWidth = 
        ISTextEntryBoxMDB:new(
            "width", 
            tostring(self.displayBar:getWidth()), 
            self:getWidth()/2 + 32, 
            y, 
            self.width - 20, 
            FONT_HGT_SMALL + 4, 
            self.displayBar)
    self.textEntryWidth:initialise();
    self.textEntryWidth:instantiate();
    --self.textEntryWidth:setTooltip(getText("ContextMenu_MinimalDisplayBars_Width"));
    self.textEntryWidth:setOnlyNumbers(true);
    self:addChild(self.textEntryWidth);
    
    self.labelWidth = 
        ISLabel:new(
            self.textEntryWidth:getX(), 
            y, 
            FONT_HGT_SMALL + 4, 
            "", 
            1, 
            1, 
            1, 
            1, 
            UIFont.Small, 
            true)
    self.labelWidth:setTranslation( labelWidthName )
    self.labelWidth:setX(self.labelWidth:getX() - self.labelWidth:getWidth())
    self.labelWidth:initialise();
    self.labelWidth:instantiate();
    self:addChild(self.labelWidth);
    y = y + self.textEntryWidth:getHeight();
    ------------------------------------
    -- Height
    self.textEntryHeight = 
        ISTextEntryBoxMDB:new(
            "height", 
            tostring(self.displayBar:getHeight()), 
            self:getWidth()/2 + 32, 
            y, 
            self.width - 20, 
            FONT_HGT_SMALL + 4, 
            self.displayBar)
    self.textEntryHeight:initialise();
    self.textEntryHeight:instantiate();
    --self.textEntryHeight:setTooltip(getText("ContextMenu_MinimalDisplayBars_Height"));
    self.textEntryHeight:setOnlyNumbers(true);
    self:addChild(self.textEntryHeight);
    
    self.labelHeight = 
        ISLabel:new(
            self.textEntryHeight:getX(), 
            y, 
            FONT_HGT_SMALL + 4, 
            "", 
            1, 
            1, 
            1, 
            1, 
            UIFont.Small, 
            true)
    self.labelHeight:setTranslation( labelHeightName )
    self.labelHeight:setX(self.labelHeight:getX() - self.labelHeight:getWidth())
    self.labelHeight:initialise();
    self.labelHeight:instantiate();
    self:addChild(self.labelHeight);
    y = y + self.textEntryHeight:getHeight() + 10;
    ------------------------------------
    -- Image Size
    self.textEntryImageSize = 
        ISTextEntryBoxMDB:new(
            "imageSize", 
            tostring(self.displayBar.imageSize), 
            self:getWidth()/2 + 32, 
            y, 
            self.width - 20, 
            FONT_HGT_SMALL + 4, 
            self.displayBar)
    self.textEntryImageSize:initialise();
    self.textEntryImageSize:instantiate();
    --self.textEntryHeight:setTooltip(getText("ContextMenu_MinimalDisplayBars_Height"));
    self.textEntryImageSize:setOnlyNumbers(true);
    self:addChild(self.textEntryImageSize);
    
    self.labelImageSize = 
        ISLabel:new(
            self.textEntryImageSize:getX(), 
            y, 
            FONT_HGT_SMALL + 4, 
            "", 
            1, 
            1, 
            1, 
            1, 
            UIFont.Small, 
            true)
    self.labelImageSize:setTranslation( labelImageSizeName )
    self.labelImageSize:setX(self.labelImageSize:getX() - self.labelImageSize:getWidth())
    self.labelImageSize:initialise();
    self.labelImageSize:instantiate();
    self:addChild(self.labelImageSize);
    y = y + self.textEntryHeight:getHeight() + 10;
    ------------------------------------
    -- Is Vertical
    local changeOptionTarget = self.displayBar
    local changeOptionMethod = function(
            displayBar, 
            mouseOverOption, 
            selected, 
            displayBarPropertiesPanel, 
            arg2)
        
        if displayBar then
            displayBar.isVertical = selected
            MinimalDisplayBars.configTables[displayBar.coopNum][displayBar.idName]["isVertical"] = selected
            
            local oldW = tonumber(displayBar.oldWidth)
            local oldH = tonumber(displayBar.oldHeight)
            displayBar:setWidth(oldH)
            displayBar:setHeight(oldW)
            
            MinimalDisplayBars.io_persistence.store(
                displayBar.fileSaveLocation, 
                MinimalDisplayBars.MOD_ID, 
                MinimalDisplayBars.configTables[displayBar.coopNum])
            
            -- recreate MoveBarsTogether panel
            MinimalDisplayBars.createMoveBarsTogetherPanel(displayBar.playerIndex)
            
            local width = displayBar:getWidth()
            local height = displayBar:getHeight()
            displayBarPropertiesPanel.textEntryWidth:setText(tostring(width))
            displayBarPropertiesPanel.textEntryHeight:setText(tostring(height))
        end
        
    end
    
    self.tickBoxIsVertical = 
        ISTickBox:new(
            self:getWidth()/2 + 32, 
            y, 
            200, 
            FONT_HGT_SMALL + 4, 
            labelSetVerticalName, 
            changeOptionTarget, 
            changeOptionMethod,
            self)
    self.tickBoxIsVertical:initialise();
    self.tickBoxIsVertical:instantiate();
    self.tickBoxIsVertical.selected[1] = self.displayBar.isVertical;
    self.tickBoxIsVertical:addOption( labelSetVerticalName );
    self:addChild(self.tickBoxIsVertical);
    --self.tickBoxIsVertical.tooltip = labelSetVerticalName;
    y = y + self.tickBoxIsVertical:getHeight() + 50;
    ------------------------------------
    self:setHeight(y)
    ------------------------------------
    
    local x = 0;
    
    self.cancelBtn = 
        ISButton:new(
            padBottom + x, 
            self:getHeight() - padBottom - btnHgt, 
            btnWid, 
            btnHgt, 
            getText("UI_btn_cancel"), 
            self, 
            ISDisplayBarPropertiesPanel.onOptionMouseDown);
    self.cancelBtn.internal = "CANCEL";
    self.cancelBtn:initialise();
    self.cancelBtn:instantiate();
    self.cancelBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.cancelBtn);
    x = x + xSpacing + btnWid;
    
    self.acceptBtn = 
        ISButton:new(
            padBottom + x, 
            self:getHeight() - padBottom - btnHgt, 
            btnWid, 
            btnHgt, 
            getText("UI_btn_accept"), 
            self, 
            ISDisplayBarPropertiesPanel.onOptionMouseDown);
    self.acceptBtn.internal = "ACCEPT";
    self.acceptBtn:initialise();
    self.acceptBtn:instantiate();
    self.acceptBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.acceptBtn);
    x = x + xSpacing + btnWid;
    
    --[[
    self.applyBtn = 
        ISButton:new(
            padBottom + btnWid*2 + x, 
            self:getHeight() - padBottom - btnHgt, 
            btnWid, 
            btnHgt, 
            getText("UI_btn_apply"), 
            self, 
            ISDisplayBarPropertiesPanel.onOptionMouseDown);
    self.applyBtn.internal = "APPLY";
    self.applyBtn:initialise();
    self.applyBtn:instantiate();
    self.applyBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.applyBtn);
    x = x + xSpacing + btnWid;
    --]]
    
    local resetTextLen = 
        getTextManager():MeasureStringX(
            UIFont.Small, 
            getText("ContextMenu_MinimalDisplayBars_RestoreYourSettings"))
    self.resetBtn = 
        ISButton:new(
            padBottom + x, 
            self:getHeight() - padBottom - btnHgt, 
            resetTextLen + 10, 
            btnHgt, 
            getText("ContextMenu_MinimalDisplayBars_RestoreYourSettings"), 
            self, 
            ISDisplayBarPropertiesPanel.onOptionMouseDown);
    self.resetBtn.internal = "RESET";
    self.resetBtn:initialise();
    self.resetBtn:instantiate();
    self.resetBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.resetBtn);
    
    --
    local width = 0
    width = width + self.cancelBtn:getWidth()
    width = width + self.acceptBtn:getWidth()
    --width = width + self.applyBtn:getWidth()
    width = width + self.resetBtn:getWidth()
    
    --[[
    for _,child in pairs(self:getChildren()) do
        width = math.max(width, child:getWidth())
    end
    for _,child in pairs(self:getChildren()) do
        child:setWidth(width)
    end
    
    --]]
    
    self:setWidth(10 + x + self.resetBtn:getWidth() + 10)
    self:setHeight(y)
    
    -- FORCE CENTER
    local core = getCore()
    self:setX( core:getScreenWidth()/2 - self:getWidth()/2 )
    self:setY( core:getScreenHeight()/2 - self:getHeight()/2 )
end

function ISDisplayBarPropertiesPanel:updateButtons()
    
end

function ISDisplayBarPropertiesPanel:onOptionMouseDown(button, x, y)
    if button.internal == "ACCEPT" then
        if self.onApply then 
            self.onApply() end
        
        if self.displayBar.parent then
            if not self.parentOldX then
                self.parentOldX = self.displayBar.parent:getX()
                self.parentOldY = self.displayBar.parent:getY()
            end
            
            self.originalConfig[self.displayBar.idName]["x"] 
                = self.originalConfig[self.displayBar.idName]["x"] + self.displayBar.parent:getX() - self.parentOldX
            self.originalConfig[self.displayBar.idName]["y"] 
                = self.originalConfig[self.displayBar.idName]["y"] + self.displayBar.parent:getY() - self.parentOldY
            
            self.parentOldX = self.displayBar.parent:getX()
            self.parentOldY = self.displayBar.parent:getY()
        end
        
        MinimalDisplayBars.configTables[self.displayBar.coopNum][self.displayBar.idName]["width"] = self.displayBar:getWidth()
        MinimalDisplayBars.configTables[self.displayBar.coopNum][self.displayBar.idName]["height"] = self.displayBar:getHeight()
        
        MinimalDisplayBars.io_persistence.store(
            self.displayBar.fileSaveLocation, 
            MinimalDisplayBars.MOD_ID, 
            MinimalDisplayBars.configTables[self.displayBar.coopNum])
        
        MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
        
        self:close()
        
    elseif button.internal == "APPLY" then
        if self.onApply then 
            self.onApply() end
        
        MinimalDisplayBars.configTables[self.displayBar.coopNum][self.displayBar.idName]["width"] = self.displayBar:getWidth()
        MinimalDisplayBars.configTables[self.displayBar.coopNum][self.displayBar.idName]["height"] = self.displayBar:getHeight()
        
        MinimalDisplayBars.io_persistence.store(
            self.displayBar.fileSaveLocation, 
            MinimalDisplayBars.MOD_ID, 
            MinimalDisplayBars.configTables[self.displayBar.coopNum])
        
        MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
        
    elseif button.internal == "RESET" then
        if self.onReset then 
            self.onReset() end
        
        if self.displayBar.parent then
            if not self.parentOldX then
                self.parentOldX = self.displayBar.parent:getX()
                self.parentOldY = self.displayBar.parent:getY()
            end
            
            self.originalConfig[self.displayBar.idName]["x"] 
                = self.originalConfig[self.displayBar.idName]["x"] + self.displayBar.parent:getX() - self.parentOldX
            self.originalConfig[self.displayBar.idName]["y"] 
                = self.originalConfig[self.displayBar.idName]["y"] + self.displayBar.parent:getY() - self.parentOldY
            
            self.parentOldX = self.displayBar.parent:getX()
            self.parentOldY = self.displayBar.parent:getY()
        end
            
        MinimalDisplayBars.configTables[self.displayBar.coopNum] = MinimalDisplayBars.deepcopy(self.originalConfig)
        
        self.displayBar:resetToConfigTable()
        
        self.textEntryX:setText(tostring(self.displayBar:getX()))
        self.textEntryY:setText(tostring(self.displayBar:getY()))
        self.textEntryHeight:setText(tostring(self.displayBar:getHeight()))
        self.textEntryWidth:setText(tostring(self.displayBar:getWidth()))
        self.textEntryImageSize:setText(tostring(self.displayBar.imageSize))
        self.tickBoxIsVertical.selected[1] = self.displayBar.isVertical;
        
        MinimalDisplayBars.io_persistence.store(
            self.displayBar.fileSaveLocation, 
            MinimalDisplayBars.MOD_ID, 
            MinimalDisplayBars.configTables[self.displayBar.coopNum])
        
        MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
        
    elseif button.internal == "CANCEL" then
        if self.onCancel then 
            self.onCancel() end
        
        MinimalDisplayBars.configTables[self.displayBar.coopNum] = MinimalDisplayBars.deepcopy(self.originalConfig)
        self.displayBar:resetToConfigTable()
        
        MinimalDisplayBars.io_persistence.store(
            self.displayBar.fileSaveLocation, 
            MinimalDisplayBars.MOD_ID, 
            MinimalDisplayBars.configTables[self.displayBar.coopNum])
        
        MinimalDisplayBars.createMoveBarsTogetherPanel(self.displayBar.playerIndex)
        
        self:close()
    end
end

function ISDisplayBarPropertiesPanel:getOriginalConfig()
    return MinimalDisplayBars.deepcopy( self.originalConfig )
end

function ISDisplayBarPropertiesPanel:close()
    self:setVisible(false)
    
    ISGenericMiniDisplayBar.isEditing = false
    
    self:removeFromUIManager()
end

function ISDisplayBarPropertiesPanel:new(x, y, displayBar)
    local o = {};
    local width, height = 200, 200
    
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    --self.player = player;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.9};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    ISDisplayBarPropertiesPanel.instance = o
    
    o.originalConfig = MinimalDisplayBars.deepcopy(MinimalDisplayBars.configTables[displayBar.coopNum])
    
    o.displayBar = displayBar
    
    if o.displayBar.parent then
        o.parentOldX = o.displayBar.parent:getX()
        o.parentOldY = o.displayBar.parent:getY()
    end
    
    ISGenericMiniDisplayBar.isEditing = true
    
    return o;
end
