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

ISReleases = ISPanel:derive("ISReleases");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function ISReleases:initialise()
    ISPanel.initialise(self);
    self:create();
end


function ISReleases:setVisible(visible)
    --    self.parent:setVisible(visible);
    self.javaObject:setVisible(visible);
end

function ISReleases:render()
    local z = 20;

    self:drawText(getText("UI_mainscreen_userpanel"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("UI_mainscreen_userpanel")) / 2), z, 1,1,1,1, UIFont.Medium);
    z = z + 30;

    self:updateButtons();

end

function ISReleases:create()
    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    
    local y = 70;
    
    local labelText = "Minimal Display Bars 4.1"
    self.titleLabel = ISLabel:new(9,16,FONT_HGT_MEDIUM, labelText ,1,1,1,1,UIFont.Medium,true)
	self.titleLabel:initialise();
    self:addChild(self.titleLabel);
    
    local width = 0
    for _,child in pairs(self:getChildren()) do
        width = math.max(width, child:getWidth())
    end
    for _,child in pairs(self:getChildren()) do
        child:setWidth(width)
    end

    self:setWidth(10 + width + 20 + width + 10)

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_btn_close"), self, ISReleases.onOptionMouseDown);
    self.cancel.internal = "CLOSE";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = self.buttonBorderColor;
    self:addChild(self.cancel);
end

function ISReleases:updateButtons()
    
end

function ISReleases:onOptionMouseDown(button, x, y)
    if button.internal == "CLOSE" then
        self:close()
    end
end

function ISReleases:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function ISReleases:new(x, y, width, height, player)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    self.player = player;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    ISReleases.instance = o
    return o;
end



local function okModal(_text, _centered, _width, _height, _posX, _posY, _func)
    local posX = _posX or 0;
    local posY = _posY or 0;
    local width = _width or 230;
    local height = _height or 120;
    local centered = _centered;
    local txt = _text;
	local func = _func or nil;
    local core = getCore();

    -- center the modal if necessary
    if centered then
        posX = core:getScreenWidth() * 0.5 - width * 0.5;
        posY = core:getScreenHeight() * 0.5 - height * 0.5;
    end

    local modal = ISModalDialog:new(posX, posY, width, height, txt, false, nil, func);
    modal:initialise();
    modal:addToUIManager();
end



Events.OnGameStart.Add(function()
    
    data = MinimalDisplayBars.LoadFromFile("_data")
    if not data or data[1] == nil then 
        data = {} end
    if data[1] == "true" then return end
    
    local fContents = MinimalDisplayBars.LoadFromFile("_ReleaseNotes.txt")
    
    local text = "";
    for i, v in ipairs(fContents) do
        if fContents[i+1] ~= nil then
            text = text .. tostring(v) .. "\r\n"
        else
            text = text .. tostring(v)
        end
    end
    
    okModal(text, true, nil, nil, nil, nil, 
                function() 
                    data = {}
                    data[1] = true
                    
                    local text = "";
                    for i, v in ipairs(data) do
                        if data[i+1] ~= nil then
                            text = text .. tostring(v) .. "\r\n"
                        else
                            text = text .. tostring(v)
                        end
                    end
                    
                    MinimalDisplayBars.SaveToFile("_data", text)
                    
                    return
                end)
    
    --[[
    local update = ISReleases:new(200, 200, 400, 400, getSpecificPlayer(0))
    update:initialise()
    update:instantiate()
    update:setVisible(true)
    --]]
    
end)




