--
--****************************
--*** Minimal Display Bars ***
--****************************
--* Coded by: ATPHHe
--* Date Created: 02/19/2020
--* Date Modified: 03/27/2020
--*******************************
--
--============================================================
local MOD_ID = "MinimalDisplayBars"

local gameVersion = getCore():getVersionNumber()
local gameVersionNum = 0
local tempIndex, _ = string.find(gameVersion, " ")
if tempIndex ~= nil then
    
    gameVersionNum = tonumber(string.sub(gameVersion, 0, tempIndex))
    if gameVersionNum == nil then 
        tempIndex, _ = string.find(gameVersion, ".") + 1 
        gameVersionNum = tonumber(string.sub(gameVersion, 0, tempIndex))
    end
else
    gameVersionNum = tonumber(gameVersion)
end
tempIndex = nil
gameVersion = nil

local defaultSettingsFileName = "MOD DefaultSettings (".. MOD_ID ..").lua"
local configFileName = "MOD Config Options (".. MOD_ID ..").lua"
--local configFileLocation = getMyDocumentFolder() .. getFileSeparator() .. configFileName

local configFileLocations = {}

local configTables = {}

local numOfLocalClients = 0
--local isSplitScreen = false

--============================================================

--*********************************************
-- Other Useful Functions

local function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        else
            print(formatting .. v)
        end
    end
end

local function deepcompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end
    return true
end

local function compare_and_insert(t1, t2, ignore_mt)
    
    local isEqual = true
    
    if not t1 then
        return false
    end
    
    if not t2 then
        t2 = {}
        isEqual = false
    end
    
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if (v2 == nil) then 
            t2[k1] = v1
            isEqual = false
        end
        
        if type(t1[k1]) == "table" then
            isEqual = compare_and_insert(t1[k1], t2[k1], ignore_mt)
        end
        
    end
    
    return isEqual
end

-- Splits the string apart.
--  EX: inputstr = "Hello There Friend."
--      sep = " "
--      t = {Hello, 
--          There, 
--          Friend.}
--  EX: inputstr = "Hello,There,Friend."
--      sep = ","
--      t = {Hello, 
--          There, 
--          Friend.}
--
-- Parameters:  inputstr - the string that will be split.
--              sep - the separator character that will be used to split the string
--              t - the table that will be returned.
--
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Returns true, if "a" a number. Otherwise return false.
local function isNumber(a)
    if tonumber(a) ~= nil then
        local number = tonumber(a)
        if number then
            return true
        end
    end
    
    return false
end


--*************************
-- I/O Functions


--[[

TablePersistence is a small code snippet that allows storing and loading of lua variables containing primitive types. It is licensed under the MIT license, use it how ever is needed. A more detailed description and complete source can be downloaded on http://the-color-black.net/blog/article/LuaTablePersistence. A fork has been created on github that included lunatest unit tests: https://github.com/hipe/lua-table-persistence

Shortcomings/Limitations:
- Does not export udata
- Does not export threads
- Only exports a small subset of functions (pure lua without upvalue)

]]
local write, writeIndent, writers, refCount;
local io_persistence =
{
	store = function (path, modID, ...)
		local file, e = getModFileWriter(modID, path, true, false) --e = io.open(path, "w");
		if not file then
			return error(e);
		end
		local n = select("#", ...);
		-- Count references
		local objRefCount = {}; -- Stores reference that will be exported
		for i = 1, n do
			refCount(objRefCount, (select(i,...)));
		end;
		-- Export Objects with more than one ref and assign name
		-- First, create empty tables for each
		local objRefNames = {};
		local objRefIdx = 0;
		file:write("-- Persistent Data (for "..modID..")\n");
		file:write("local multiRefObjects = {\n");
		for obj, count in pairs(objRefCount) do
			if count > 1 then
				objRefIdx = objRefIdx + 1;
				objRefNames[obj] = objRefIdx;
				file:write("{};"); -- table objRefIdx
			end;
		end;
		file:write("\n} -- multiRefObjects\n");
		-- Then fill them (this requires all empty multiRefObjects to exist)
		for obj, idx in pairs(objRefNames) do
			for k, v in pairs(obj) do
				file:write("multiRefObjects["..idx.."][");
				write(file, k, 0, objRefNames);
				file:write("] = ");
				write(file, v, 0, objRefNames);
				file:write(";\n");
			end;
		end;
		-- Create the remaining objects
		for i = 1, n do
			file:write("local ".."obj"..i.." = ");
			write(file, (select(i,...)), 0, objRefNames);
			file:write("\n");
		end
		-- Return them
		if n > 0 then
			file:write("return obj1");
			for i = 2, n do
				file:write(" ,obj"..i);
			end;
			file:write("\n");
		else
			file:write("return\n");
		end;
		if type(path) == "string" then
			file:close();
		end;
	end;

	load = function (path, modID)
		local f, e;
		if type(path) == "string" then
            --f, e = loadfile(path);
			f, e = getModFileReader(modID, path, true);
            if f == nil then f = getFileReader(sourceFile, true) end;
            
            local contents = "";
            local scanLine = f:readLine();
            while scanLine do
                
                contents = contents.. scanLine .."\r\n";
                
                scanLine = f:readLine();
                if not scanLine then break end
            end
            
            f:close();
            
            f = contents;
		else
			f, e = path:read('*a');
		end
		if f then
            local func = loadstring(f);
            if func then
                return func();
            else
                return nil;
            end
		else
			return nil, e;
		end;
	end;
}

-- Private methods

-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
	for i = 1, level do
		file:write("\t");
	end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item)
			file:write("nil");
		end;
	["number"] = function (file, item)
			file:write(tostring(item));
		end;
	["string"] = function (file, item)
			file:write(string.format("%q", item));
		end;
	["boolean"] = function (file, item)
			if item then
				file:write("true");
			else
				file:write("false");
			end
		end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				-- Table with multiple references
				file:write("multiRefObjects["..refIdx.."]");
			else
				-- Single use table
				file:write("{\r\n");
				for k, v in pairs(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\r\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			-- Does only work for "normal" functions, not those
			-- with upvalues or c functions
			local dInfo = debug.getinfo(item, "uS");
			if dInfo.nups > 0 then
				file:write("nil --[[functions with upvalue not supported]]");
			elseif dInfo.what ~= "Lua" then
				file:write("nil --[[non-lua function not supported]]");
			else
				local r, s = pcall(string.dump,item);
				if r then
					file:write(string.format("loadstring(%q)", s));
				else
					file:write("nil --[[function could not be dumped]]");
				end
			end
		end;
	["thread"] = function (file, item)
			file:write("nil --[[thread]]\r\n");
		end;
	["userdata"] = function (file, item)
			file:write("nil --[[userdata]]\r\n");
		end;
}

-- Testing Persistence
--io_persistence.store("storage.lua", MOD_ID, configTables)
--t_restored = io_persistence.load("storage.lua", MOD_ID);
--io_persistence.store("storage2.lua", MOD_ID, t_restored)



-- Save to a destination file.
-- Returns true if successful, otherwise return false if an error occured.
local function SaveToFile(destinationFile, text)
    local fileWriter = getModFileWriter(MOD_ID, destinationFile, true, false)
    if fileWriter == nil then fileWriter = getFileWriter(destinationFile, true, false) end
    
    fileWriter:write(tostring(text))
    fileWriter:close()
end

-- Load from a sourceFile file.
-- Returns a table of Strings, representing each line in the file.
local function LoadFromFile(sourceFile)

	local contents = {}
	local fileReader = getModFileReader(MOD_ID, sourceFile, true)
    if fileReader == nil then fileReader = getFileReader(sourceFile, true) end
    
	local scanLine = fileReader:readLine()
	while scanLine do
        
        table.insert(contents, tostring(scanLine))
        
		scanLine = fileReader:readLine()
		if not scanLine then break end
	end
    
	fileReader:close();
    
	return contents
end

-- Recreates the default configuration files for this mod.
local function recreateConfigFiles(locationIndex)
    local fileContents1 = io_persistence.load(defaultSettingsFileName, MOD_ID)
    io_persistence.store(configFileLocations[locationIndex], MOD_ID, fileContents1)
    return fileContents1
end


--*********************************************
-- Custom Tables
local DEFAULT_SETTINGS = {
    
    ["lock_all_bars"] = false,
    
    ["menu"] = {
        ["x"] = 126,
        ["y"] = 15,
        ["width"] = 15,
        ["height"] = 15,
        ["l"] = 3,
        ["t"] = 3,
        ["r"] = 3,
        ["b"] = 3,
        ["color"] = {red = (255 / 255), 
                    green = (255 / 255), 
                    blue = (255 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["hp"] = {
        ["x"] = 70,
        ["y"] = 30,
        ["width"] = 15,
        ["height"] = 150,
        ["l"] = 3,
        ["t"] = 3,
        ["r"] = 3,
        ["b"] = 3,
        ["color"] = {red = (0 / 255), 
                    green = (128 / 255), 
                    blue = (0 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["hunger"] = {
        ["x"] = 70 + 15,
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (255 / 255), 
                    green = (255 / 255), 
                    blue = (10 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["thirst"] = {
        ["x"] = 85 + (8 * 1),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (173 / 255), 
                    green = (216 / 255), 
                    blue = (230 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["endurance"] = {
        ["x"] = 85 + (8 * 2),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (244 / 255), 
                    green = (244 / 255), 
                    blue = (244 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["fatigue"] = {
        ["x"] = 85 + (8 * 3),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (240 / 255), 
                    green = (240 / 255), 
                    blue = (170 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["boredomlevel"] = {
        ["x"] = 85 + (8 * 4),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (170 / 255), 
                    green = (170 / 255), 
                    blue = (170 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["unhappynesslevel"] = {
        ["x"] = 85 + (8 * 5),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (128 / 255), 
                    green = (128 / 255), 
                    blue = (255 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    ["temperature"] = {
        ["x"] = 85 + (8 * 6),
        ["y"] = 30,
        ["width"] = 8,
        ["height"] = 150,
        ["l"] = 2,
        ["t"] = 3,
        ["r"] = 2,
        ["b"] = 3,
        ["color"] = {red = (0 / 255), 
                    green = (255 / 255), 
                    blue = (0 / 255), 
                    alpha = 0.75},
        ["isMovable"] = true,
        ["isResizable"] = false,
        ["isVisible"] = true,
        ["isVertical"] = true,
        ["alwaysBringToTop"] = true,
        ["showMoodletThresholdLines"] = true,
        ["isCompact"] = false,
        },
    
    
    }


--**********************************************
-- Vanilla Functions


--*************************************
-- Custom Functions

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function rgbToHsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    local s
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, l}
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
]]
function hslToRgb(h, s, l)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    function hue2rgb(p, q, t)
      if t < 0   then t = t + 1 end
      if t > 1   then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end

  return {r * 255, g * 255, b * 255}
end

--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
function rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return {h, s, v}
end

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return {r * 255, g * 255, b * 255}
end


-- Display bars are stored here so that they may be accessed by the ContextMenu.
local barMenu = {}
local barHP = {}
local barHunger = {}
local barThirst = {}
local barEndurance = {}
local barFatigue = {}
local barBoredomLevel = {}
local barUnhappynessLevel = {}
local barTemperature = {}

local displayBars = {} -- This should store all the display bars as they are created.


local function toggleMovable(bar)
    if bar.moveWithMouse then
        bar.moveWithMouse = false
        configTables[bar.coopNum][bar.idName]["isMovable"] = false
    else
        bar.moveWithMouse = true
        configTables[bar.coopNum][bar.idName]["isMovable"] = true
    end
end

local function toggleResizeable(bar)
    if bar.resizeWithMouse then
        bar.resizeWithMouse = false
        configTables[bar.coopNum][bar.idName]["isResizable"] = false
    else
        bar.resizeWithMouse = true
        configTables[bar.coopNum][bar.idName]["isResizable"] = true
    end
end

local function toggleAlwaysBringToTop(bar)
    if bar.alwaysBringToTop then
        bar.alwaysBringToTop = false
        configTables[bar.coopNum][bar.idName]["alwaysBringToTop"] = false
    else
        bar.alwaysBringToTop = true
        configTables[bar.coopNum][bar.idName]["alwaysBringToTop"] = true
    end
end

local function toggleMoodletThresholdLines(bar)
    if bar.showMoodletThresholdLines then
        bar.showMoodletThresholdLines = false
        configTables[bar.coopNum][bar.idName]["showMoodletThresholdLines"] = false
    else
        bar.showMoodletThresholdLines = true
        configTables[bar.coopNum][bar.idName]["showMoodletThresholdLines"] = true
    end
end

local function toggleCompact(bar)
    if bar.isCompact then
        bar.isCompact = false
        configTables[bar.coopNum][bar.idName]["isCompact"] = false
        configTables[bar.coopNum][bar.idName]["height"] = 150
    else
        bar.isCompact = true
        configTables[bar.coopNum][bar.idName]["isCompact"] = true
        configTables[bar.coopNum][bar.idName]["height"] = 75
    end
    bar:resetToconfigTable() 
end


-- ContextMenu
local function showContextMenu(generic_bar, dx, dy)
	local contextMenu = ISContextMenu.get(
                            generic_bar.playerIndex, 
                            (generic_bar.x + dx), (generic_bar.y + dy), 1, 1)
    -- Title
	contextMenu:addOption("--- " .. getText("ContextMenu_MinimalDisplayBars_Title") .. " ---")
    
    -- Display Bar Name
    contextMenu:addOption("==/   " .. getText("ContextMenu_MinimalDisplayBars_".. generic_bar.idName .."") .. "   \\==")
    
    -- === Menu ===
    if generic_bar.idName == "menu" then
    
        -- Reset
        contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Reset"),
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        
                        configTables[generic_bar.coopNum] = io_persistence.load(defaultSettingsFileName, MOD_ID)
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        if generic_bar then 
                            generic_bar:resetToconfigTable() end
                        
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                bar:resetToconfigTable() end
                        end
                        
                        return
                    end)
        
        --[[local subMenu = ISContextMenu:getNew(contextMenu)
        contextMenu:addSubMenu(
            contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Reset_Display_Bar")), subMenu)
        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
            if bar then 
                subMenu:addOption(
                        getText("ContextMenu_MinimalDisplayBars_".. bar.idName ..""),
                        nil,
                        function()
                            
                            
                            
                            io_persistence.store(bar.fileSaveLocation, MOD_ID, configTables[bar.coopNum])
                            
                            return
                        end
                )
            end
        end]]
        
        -- Show Display Bar
        local subMenu = ISContextMenu:getNew(contextMenu)
        subMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Show_All_Display_Bars"),
                    generic_bar,
                    function(generic_bar)
                        
                        if not generic_bar then return end
                        
                        --[[if generic_bar then 
                            configTables[generic_bar.coopNum][generic_bar.idName]["isVisible"] = true
                            generic_bar:setVisible(true) 
                        end]]
                        
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                configTables[bar.coopNum][bar.idName]["isVisible"] = true
                                bar:setVisible(true) 
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
            if bar then 
                subMenu:addOption(
                        getText("ContextMenu_MinimalDisplayBars_".. bar.idName ..""),
                        nil,
                        function()
                            configTables[bar.coopNum][bar.idName]["isVisible"] = true
                            bar:setVisible(true)
                            
                            io_persistence.store(bar.fileSaveLocation, MOD_ID, configTables[bar.coopNum])
                            
                            return
                        end
                )
            end
        end
        contextMenu:addSubMenu(
            contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Show_Bar")), subMenu)
        
        -- Hide Display Bar
        local subMenu = ISContextMenu:getNew(contextMenu)
        subMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Hide_All_Display_Bars"),
                    generic_bar,
                    function(generic_bar)
                        
                        if not generic_bar then return end
                        
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                configTables[bar.coopNum][bar.idName]["isVisible"] = false
                                bar:setVisible(false) 
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
            if bar then 
                subMenu:addOption(
                        getText("ContextMenu_MinimalDisplayBars_".. bar.idName ..""),
                        nil,
                        function()
                            configTables[bar.coopNum][bar.idName]["isVisible"] = false
                            bar:setVisible(false)
                            
                            io_persistence.store(bar.fileSaveLocation, MOD_ID, configTables[bar.coopNum])
                            
                            return
                        end
                )
            end
        end
        contextMenu:addSubMenu(
            contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Hide_Bar")), subMenu)
        
        -- Toggle Movable All
        local str
        if barHP[generic_bar.playerIndex].moveWithMouse == true then
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Movable_All")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_ON")..")"
        else
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Movable_All")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_OFF")..")"
        end
        contextMenu:addOption(
                    str,
                    generic_bar,
                    function(generic_bar)

                        if not generic_bar then return end
                        
                        if generic_bar then 
                            toggleMovable(generic_bar) end
                        
                        toggleMovable(barHP[generic_bar.playerIndex]) 
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                if barHP[generic_bar.playerIndex].moveWithMouse ~= bar.moveWithMouse then
                                    toggleMovable(bar) 
                                end
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        
                        return
                    end)
                    
        -- Toggle Resizable All
        --[[local str
        if barHP[generic_bar.playerIndex].resizeWithMouse == true then
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Resizable_All")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_ON")..")"
        else
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Resizable_All")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_OFF")..")"
        end
        contextMenu:addOption(
                    str,
                    generic_bar,
                    function(generic_bar)

                        if not generic_bar then return end
                        
                        toggleResizeable(barHP[generic_bar.playerIndex]) 
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                if barHP[generic_bar.playerIndex].resizeWithMouse ~= bar.resizeWithMouse then
                                    toggleResizeable(bar) 
                                end
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        
                        return
                    end)]]
        
        -- Toggle Always Bring Display Bars To Top
        local str
        if barHP[generic_bar.playerIndex].alwaysBringToTop == true then
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Always_Bring_Display_Bars_To_Top")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_ON")..")"
        else
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Always_Bring_Display_Bars_To_Top")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_OFF")..")"
        end
        contextMenu:addOption(
                    str,
                    generic_bar,
                    function(generic_bar)
                        
                        if not generic_bar then return end
                        
                        toggleAlwaysBringToTop(barHP[generic_bar.playerIndex])
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                if barHP[generic_bar.playerIndex].alwaysBringToTop ~= bar.alwaysBringToTop then
                                    toggleAlwaysBringToTop(bar) 
                                end
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
                    
        -- Toggle Moodlet Threshold Lines
        local str
        if barHP[generic_bar.playerIndex].showMoodletThresholdLines == true then
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Moodlet_Threshold_Lines")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_ON")..")"
        else
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Moodlet_Threshold_Lines")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_OFF")..")"
        end
        contextMenu:addOption(
                    str,
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        
                        toggleMoodletThresholdLines(barHP[generic_bar.playerIndex]) 
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                if barHP[generic_bar.playerIndex].showMoodletThresholdLines ~= bar.showMoodletThresholdLines then
                                    toggleMoodletThresholdLines(bar) 
                                end
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
                    
        -- Toggle Compact
        local str
        if barHP[generic_bar.playerIndex].isCompact == true then
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Compact")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_ON")..")"
        else
            str = getText("ContextMenu_MinimalDisplayBars_Toggle_Compact")
                        .." ("..getText("ContextMenu_MinimalDisplayBars_OFF")..")"
        end
        contextMenu:addOption(
                    str,
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        
                        toggleCompact(barHP[generic_bar.playerIndex]) 
                        for k, bar in pairs(displayBars[generic_bar.playerIndex]) do
                            if bar then 
                                if barHP[generic_bar.playerIndex].isCompact ~= bar.isCompact then
                                    toggleCompact(bar) 
                                end
                            end
                        end
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
    else
    
    -- === Display Bars ===
        contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Reset_Display_Bar"),
                    generic_bar,
                    function(generic_bar)
                        
                        if not generic_bar then return end
                        
                        local DEFAULTS = io_persistence.load(defaultSettingsFileName, MOD_ID)
                        for k, v in pairs(configTables[generic_bar.coopNum][generic_bar.idName]) do
                            
                            -- Ignore resetting these toggle options
                            if k ~= "isMovable" 
                               and k ~= "isResizable" 
                               and k ~= "alwaysBringToTop" 
                               and k ~= "showMoodletThresholdLines" 
                               then
                               
                                configTables[generic_bar.coopNum][generic_bar.idName][k] = DEFAULTS[generic_bar.idName][k]
                                
                            end
                            
                        end
                        
                        -- reset
                        if generic_bar then 
                            generic_bar:resetToconfigTable() 
                        end
                        
                        -- fix other toggles
                        if barHP[generic_bar.playerIndex].isCompact ~= generic_bar.isCompact then
                            toggleCompact(generic_bar)
                        end
                        
                        -- store options
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
        contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Set_Vertical"),
                    generic_bar,
                    function(generic_bar)
                        
                        if not generic_bar then return end
                        
                        if configTables[generic_bar.coopNum][generic_bar.idName]["isVertical"] == false then 
                            generic_bar.isVertical = true
                            configTables[generic_bar.coopNum][generic_bar.idName]["isVertical"] = true
                            
                            local oldW = tonumber(generic_bar.oldWidth)
                            local oldH = tonumber(generic_bar.oldHeight)
                            generic_bar:setWidth(oldH)
                            generic_bar:setHeight(oldW)
                            
                            io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        end
                        return
                    end)
        contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Set_Horizontal"),
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        
                        if configTables[generic_bar.coopNum][generic_bar.idName]["isVertical"] == true then 
                            generic_bar.isVertical = false
                            configTables[generic_bar.coopNum][generic_bar.idName]["isVertical"] = false
                            
                            local oldW = tonumber(generic_bar.oldWidth)
                            local oldH = tonumber(generic_bar.oldHeight)
                            generic_bar:setWidth(oldH)
                            generic_bar:setHeight(oldW)
                            
                            io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        end
                        return
                    end)
        --[[contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Set_Color"),
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        
                        local colorPicker = ISColorPicker:new(contextMenu.x, contextMenu.y)
						generic_bar.colorPicker = colorPicker
						colorPicker:initialise()
                        
						colorPicker:setInitialColor(
                            ColorInfo.new(
                                generic_bar.color.red, 
                                generic_bar.color.green, 
                                generic_bar.color.blue, 
                                generic_bar.color.alpha)
                            )
                            
						colorPicker.pickedTarget = generic_bar
						colorPicker.pickedFunc = 
                            function(generic_bar, color)
								generic_bar.color = {
                                    red = color.red, 
                                    green = color.green, 
                                    blue = color.blue, 
                                    alpha = generic_bar.color.alpha
                                }
                                    
								configTables[generic_bar.coopNum][generic_bar.idName]["color"] = generic_bar.color
								io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
								return
							end
                            
						local screenHeight = getCore():getScreenHeight()
						local colorPickerBottom = (colorPicker.y + colorPicker.height)
						if colorPickerBottom > screenHeight then
							colorPicker.y = (colorPicker.y - (colorPickerBottom - screenHeight))
						end
                        
						local screenWidth = getCore():getScreenWidth()
						local colorPickerRight = (colorPicker.x + colorPicker.width)
						if colorPickerRight > screenWidth then
							colorPicker.x = (colorPicker.x - (colorPickerRight - screenWidth))
						end
                        
						colorPicker:addToUIManager()
                        
						return
                    end)]]
        contextMenu:addOption(getText("ContextMenu_MinimalDisplayBars_Hide"),
                    generic_bar,
                    function(generic_bar)
                    
                        if not generic_bar then return end
                        generic_bar:setVisible(false)
                        configTables[generic_bar.coopNum][generic_bar.idName]["isVisible"] = false
                        
                        io_persistence.store(generic_bar.fileSaveLocation, MOD_ID, configTables[generic_bar.coopNum])
                        
                        return
                    end)
    end
    
end

-- GenericMiniDisplayBar
local GenericMiniDisplayBar = ISPanel:derive("GenericMiniDisplayBar")

function GenericMiniDisplayBar:setWidth(w, ...)
    local panel = ISPanel.setWidth(self, w, ...)
    self.oldWidth = self.width
    self.innerWidth = (self.width - self.borderSizes.l - self.borderSizes.r)
    return panel
end

function GenericMiniDisplayBar:setHeight(h, ...)
    local panel = ISPanel.setHeight(self, h, ...)
    self.oldHeight = self.height
    self.innerHeight = (self.height - self.borderSizes.t - self.borderSizes.b)
    return panel
end

function GenericMiniDisplayBar:onMouseDoubleClick(x, y, ...)
    return
end

function GenericMiniDisplayBar:onRightMouseDown(x, y, ...)
    local result = ISPanel.onRightMouseDown(self, x, y, ...)
    self.rightMouseDown = true
    return result
end

function GenericMiniDisplayBar:onRightMouseUp(dx, dy, ...)
    local panel = ISPanel.onRightMouseUp(self, dx, dy, ...)
    if self.rightMouseDown == true then showContextMenu(self, dx, dy) end
	self.rightMouseDown = false
    return panel
end

function GenericMiniDisplayBar:onRightMouseUpOutside(x, y, ...)
	local panel = ISPanel.onRightMouseUpOutside(self, x, y, ...)
	self.rightMouseDown = false
	return panel
end

function GenericMiniDisplayBar:onMouseDown(x, y, ...)
    local panel = ISPanel.onMouseDown(self, x, y, ...)
    self.oldX = self.x
    self.oldY = self.y
    return panel
end

function GenericMiniDisplayBar:render(...)
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
	if self.moving or self.resizing then
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
        -- (str, x, y, r, g, b, a, font)
        self:drawText(
            ("x: "..self.x.." \r\ny: "..self.y),
            self.borderSizes.l,
            self.borderSizes.t,
            1,
            1,
            1,
            1,
            UIFont.Small)
    end

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
            configTables[self.coopNum][self.idName]["x"] = self.x - self.xOffset
            configTables[self.coopNum][self.idName]["y"] = self.y - self.yOffset
            io_persistence.store(self.fileSaveLocation, MOD_ID, configTables[self.coopNum])
        end
    end
    
    -- Force to the top of UI if true.
    if self.alwaysBringToTop == true then self:bringToTop() end
    
    return panel
end

function GenericMiniDisplayBar:resetToconfigTable(...)
    --local panel = ISPanel.resetToconfigTable(self, ...)
    
    self.x = (configTables[self.coopNum][self.idName]["x"] + self.xOffset)
    self.y = (configTables[self.coopNum][self.idName]["y"] + self.yOffset)
    self.oldX = self.x
    self.oldY = self.y
    
    self:setWidth(configTables[self.coopNum][self.idName]["width"])
    self:setHeight(configTables[self.coopNum][self.idName]["height"])
    
    self.oldWidth = self.width
    self.oldHeight = self.height
    
	self.moveWithMouse = configTables[self.coopNum][self.idName]["isMovable"]
	self.resizeWithMouse = configTables[self.coopNum][self.idName]["isResizable"]
    
	self.borderSizes = {l = configTables[self.coopNum][self.idName]["l"], 
                        t = configTables[self.coopNum][self.idName]["t"], 
                        r = configTables[self.coopNum][self.idName]["r"], 
                        b = configTables[self.coopNum][self.idName]["b"]}
	self.innerWidth = (self.width - self.borderSizes.l - self.borderSizes.r)
	self.innerHeight = (self.height - self.borderSizes.t - self.borderSizes.b)
	self.color = configTables[self.coopNum][self.idName]["color"]
	self.minimumWidth = (1 + self.borderSizes.l + self.borderSizes.r)
	self.minimumHeight = (1 + self.borderSizes.t + self.borderSizes.b)
    
    self.isVertical = configTables[self.coopNum][self.idName]["isVertical"]
    
    self.showMoodletThresholdLines = configTables[self.coopNum][self.idName]["showMoodletThresholdLines"]
    --self.moodletThresholdTable = moodletThresholdTable
    
    self.isCompact = configTables[self.coopNum][self.idName]["isCompact"]
    
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
    
	self:setVisible(configTables[self.coopNum][self.idName]["isVisible"])
    
    self.alwaysBringToTop = configTables[self.coopNum][self.idName]["alwaysBringToTop"]
    --self:setAlwaysOnTop(true)
    --return panel
end

function GenericMiniDisplayBar:new(
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
    
    self.alwaysBringToTop = configTable[idName]["alwaysBringToTop"]
    --panel:setAlwaysOnTop(true)
    
	return panel
end

--==========================
-- Health Functions
local function calcHealth(value)
    return value / 100 
end
local function getHealth(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcHealth( isoPlayer:getBodyDamage():getHealth() ) 
    end
end

local frameRate = 60
local oldFrameRate = 60
local tickRate = 120
local hpTickCounter = 0
local performance = getPerformance()
local function onTickHP()
    hpTickCounter = hpTickCounter + 1
    
    if hpTickCounter >= tickRate then
        hpTickCounter = 0
        if frameRate ~= oldFrameRate then
            tickRate = 60 + performance:getFramerate()
        end
    end
    
end

local hpWarningFlash = {}
local onPlayerUpdateTick = 0
local function onPlayerUpdateCheckBodyDamage(isoPlayer)
    
    if onPlayerUpdateTick < 15 then 
        onPlayerUpdateTick = onPlayerUpdateTick + 1
        return;
    else
        onPlayerUpdateTick = 0
    end
    
    local bodyParts = isoPlayer:getBodyDamage():getBodyParts();
    local size = bodyParts:size()-1;
    for i=0, size do
        local bodyPart = bodyParts:get(i);
        
        local bandageLife = bodyPart:getBandageLife();
        local bandaged = bodyPart:bandaged();
        local stitched = bodyPart:stitched();
        local isSplint = bodyPart:isSplint();
        local bitten = bodyPart:bitten();
        local bleeding = bodyPart:bleeding();
        local scratched = bodyPart:scratched();
        local deepWounded = bodyPart:isDeepWounded();
        local burnTime = bodyPart:getBurnTime();
        local fractureTime = bodyPart:getFractureTime();
        local haveBullet = bodyPart:haveBullet();
        if --(bandageLife <= 0 and bandaged)
                (deepWounded and not stitched) 
                or (bitten and not bandaged) 
                or (bleeding and not bandaged) 
                or (scratched and not bandaged) 
                or (deepWounded and not bandaged) 
                or (burnTime > 0.0 and not bandaged) 
                or (fractureTime > 0.0 and not isSplint)
                or (haveBullet) then
            hpWarningFlash[isoPlayer] = true;
            break;
        end
        
        if i >= size then 
            hpWarningFlash[isoPlayer] = false; 
        end
    end
    
    --print(isoPlayer:getBodyDamage():getPoisonLevel())
    if isoPlayer:getBodyDamage():getNumPartsBleeding() >= 1
            or isoPlayer:getBodyDamage():getInfectionLevel() >= 31.7 
            or isoPlayer:getBodyDamage():getFakeInfectionLevel() >= 31.7
            or isoPlayer:getMoodles():getMoodleLevel(MoodleType.FromString("Sick")) == 4
            or isoPlayer:getMoodles():getMoodleLevel(MoodleType.FromString("Thirst")) == 4
            or isoPlayer:getMoodles():getMoodleLevel(MoodleType.FromString("Hungry")) == 4 
            or (isoPlayer:getBodyDamage():getPoisonLevel() > 10.0 
                and isoPlayer:getMoodles():getMoodleLevel(MoodleType.FromString("Sick")) >= 1)
            or isoPlayer:getBodyDamage():isIsOnFire()
            or isoPlayer:getMoodles():getMoodleLevel(MoodleType.FromString("Bleeding")) >= 1 then
        hpWarningFlash[isoPlayer] = true;
    end
    
    return;
end

local function getColorHP(isoPlayer) 
    local hpRatio = 0
    
    if not isoPlayer:isDead() then
        hpRatio = getHealth(isoPlayer) 
    end
    
    local color
    if 0 <= hpRatio and hpRatio < 1 then
        color = { red = (255 / 255), 
                    green = (255 / 255) * (math.pow(0.1, 1 - hpRatio)), 
                    blue = (10 / 255) * (1 - hpRatio), 
                    alpha = 0.75 }
    elseif hpRatio < 0 then
        color = { red = (255 / 255), 
                    green = (0 / 255), 
                    blue = (0 / 255), 
                    alpha = 0.75 }
    else
        color = { red = (255 / 255) * (1 - hpRatio), 
                    green = (128 / 255) * (hpRatio), 
                    blue = (10 / 255) * (1 - hpRatio), 
                    alpha = 0.75 }
    end
    
    if hpWarningFlash[isoPlayer] then
        local hsv = rgbToHsv(color.red, color.green, color.blue)
        local sat = 0.5 * math.sin(hpTickCounter / 30 * math.pi) + 0.5
        
        local rgb = hsvToRgb(hsv[1], sat, hsv[3])
        --print(rgb[1] .. " " .. rgb[2] .. " " .. rgb[3])
        color.red = rgb[1]
        color.green = rgb[2]
        color.blue = rgb[3]
    end
    
    --print(hpWarningFlash[isoPlayer])
    
    return color
end

-- Hunger Functions
local function calcHunger(value)
    return 1 - value
end
local function getHunger(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcHunger( isoPlayer:getStats():getHunger() )
    end
end

local function getColorHunger(isoPlayer) 
    local color
    color = configTables[1]["hunger"]["color"]
    return color
end

-- Thirst Functions
local function calcThirst(value)
    return 1 - value
end
local function getThirst(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcThirst( isoPlayer:getStats():getThirst() )
    end
end

local function getColorThirst(isoPlayer) 
    local color
    color = configTables[1]["thirst"]["color"]
    return color
end

-- Endurance Functions
local function calcEndurance(value)
    return value
end
local function getEndurance(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcEndurance( isoPlayer:getStats():getEndurance() )
    end
end

local function getColorEndurance(isoPlayer) 
    local color
    color = configTables[1]["endurance"]["color"]
    return color
end

-- Fatigue Functions
local function calcFatigue(value)
    return value
end
local function getFatigue(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcFatigue( isoPlayer:getStats():getFatigue() )
    end
end

local function getColorFatigue(isoPlayer) 
    local color
    color = configTables[1]["fatigue"]["color"]
    return color
end

-- BoredomLevel Functions
local function calcBoredomLevel(value)
    return value / 100
end
local function getBoredomLevel(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcBoredomLevel( isoPlayer:getBodyDamage():getBoredomLevel() )
    end
end

local function getColorBoredomLevel(isoPlayer) 
    local color
    color = configTables[1]["boredomlevel"]["color"]
    return color
end

-- UnhappynessLevel (UnhappinessLevel) Functions
local function calcUnhappynessLevel(value)
    --print(value)
    return value / 100
end
local function getUnhappynessLevel(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcUnhappynessLevel( isoPlayer:getBodyDamage():getUnhappynessLevel() )
    end
end

local function getColorUnhappynessLevel(isoPlayer) 
    local color
    color = configTables[1]["unhappynesslevel"]["color"]
    return color
end

-- Temperature Functions
local maxTempLim = 41  -- 41.0 C
local minTempLim = 19  -- 19.0 C
local function calcTemperature(value)
    return (value - minTempLim) / (maxTempLim - minTempLim)
end
local function getTemperature(isoPlayer) 
    if isoPlayer:isDead() then
        return -1
    else
        return calcTemperature( isoPlayer:getBodyDamage():getTemperature() )
    end
end

local function getColorTemperature(isoPlayer) 
    local tempRatio = getTemperature(isoPlayer) 
    
    local color
    if calcTemperature(20.0) <= tempRatio and tempRatio < calcTemperature(36.5) then
        local hue = (180 + (80 - 80 * ( (tempRatio - calcTemperature(20.0)) / (calcTemperature(36.5) - calcTemperature(minTempLim)) ))) / 360
        local rgb = hsvToRgb(hue, 1, 1)
        --print(hue * 360)
        --print(rgb[1].." "..rgb[2].." "..rgb[3])
        color = { red = rgb[1] / 255, 
                    green = rgb[2] / 255, 
                    blue = rgb[3] / 255, 
                    alpha = 0.75 }
    elseif calcTemperature(36.5) <= tempRatio and tempRatio <= calcTemperature(37.5) then
        local hue = (60 + (120 - 120 * ( (tempRatio - calcTemperature(36.5)) / (calcTemperature(37.5) - calcTemperature(36.5)) ))) / 360
        local rgb = hsvToRgb(hue, 1, 1)
        --print(hue * 360)
        --print(rgb[1].." "..rgb[2].." "..rgb[3])
        color = { red = rgb[1] / 255, 
                    green = rgb[2] / 255, 
                    blue = rgb[3] / 255, 
                    alpha = 0.75 }
    elseif calcTemperature(37.5) < tempRatio and tempRatio <= calcTemperature(40.0) then
        local hue = (0 + (60 - 60 * ( (tempRatio - calcTemperature(37.5)) / (calcTemperature(40.0) - calcTemperature(37.5)) ))) / 360
        local rgb = hsvToRgb(hue, 1, 1)
        --print(hue * 360)
        --print(rgb[1].." "..rgb[2].." "..rgb[3])
        color = { red = rgb[1] / 255, 
                    green = rgb[2] / 255, 
                    blue = rgb[3] / 255, 
                    alpha = 0.75 }
    else
        color = { red = (255 / 255), 
                    green = (255 / 255), 
                    blue = (255 / 255), 
                    alpha = 0.75 }
    end
    
    return color
end

--============================
-- Moodlet Threshold Tables
local function getMoodletThresholdTables() 
    local t = {
        ["hp"] = {
            [1] = calcHealth(25), -- 25 / 100
            [2] = calcHealth(50),
            [3] = calcHealth(75),
            },
        ["hunger"] = {
            [1] = calcHunger(0.15), -- 0.15 / 1.00
            [2] = calcHunger(0.25),
            [3] = calcHunger(0.45),
            [4] = calcHunger(0.70),
            },
        ["thirst"] = {
            [1] = calcThirst(0.12), -- 0.12 / 1.00
            [2] = calcThirst(0.25),
            [3] = calcThirst(0.70),
            [4] = calcThirst(0.84),
            },
        ["endurance"] = {
            [1] = calcEndurance(0.10), -- 0.10 / 1.00
            [2] = calcEndurance(0.25),
            [3] = calcEndurance(0.50),
            [4] = calcEndurance(0.75),
            },
        ["fatigue"] = {
            [1] = calcFatigue(0.60), -- 0.60 / 1.00
            [2] = calcFatigue(0.70),
            [3] = calcFatigue(0.80),
            [4] = calcFatigue(0.90),
            },
        ["boredomlevel"] = {
            [1] = calcBoredomLevel(25), -- 25/100
            [2] = calcBoredomLevel(50),
            [3] = calcBoredomLevel(75),
            [4] = calcBoredomLevel(90),
            },
        ["unhappynesslevel"] = {
            [1] = calcUnhappynessLevel(20), -- 20/100
            [2] = calcUnhappynessLevel(45),
            [3] = calcUnhappynessLevel(60),
            [4] = calcUnhappynessLevel(80),
            },
        ["temperature"] = {
            [1] = calcTemperature(30.0), -- 30.0 C (MIN: 19.0 C, MAX: 41.0 C)
            [2] = calcTemperature(25.0),
            [3] = calcTemperature(36.5),
            [4] = calcTemperature(37.5),
            [5] = calcTemperature(39.0),
            },
            
            
        }
    
    return t
end

--=============================================
-- UI

local playerIndices = {} -- added for split-screen support

-- added for split-screen support
local function OnBootGame() 
    playerIndices = {}
    --numOfLocalClients = 0
end

-- added for split-screen support
local function OnLocalPlayerDisconnect(isoPlayer)
    if isoPlayer:isLocalPlayer() then
    
        --[[numOfLocalClients = numOfLocalClients - 1
        if numOfLocalClients < 0 then 
            numOfLocalClients = 0 
        end]]
        
        for k, v in pairs(playerIndices) do
            if playerIndices[k] == isoPlayer:getPlayerNum() + 1 then
                table.remove(playerIndices, k)
                break
            end
        end
        
    end
end

-- added for split-screen support
--[[local function OnLocalPlayerDeath(isoPlayer)
    if isoPlayer:isLocalPlayer() then
        numOfLocalClients = numOfLocalClients - 1
        if numOfLocalClients < 0 then 
            numOfLocalClients = 0 
        end
    end
end]]


-- Give default settings to config opts.
--[[configFileLocations[1] = configFileName
configFileLocations[2] = configFileName .. " P2.lua"
configFileLocations[3] = configFileName .. " P3.lua"
configFileLocations[4] = configFileName .. " P4.lua"

configTables[1] = io_persistence.load(defaultSettingsFileName, MOD_ID)
configTables[2] = io_persistence.load(defaultSettingsFileName, MOD_ID)
configTables[3] = io_persistence.load(defaultSettingsFileName, MOD_ID)
configTables[4] = io_persistence.load(defaultSettingsFileName, MOD_ID)

for i=1, 4, 1 do 
    if not deepcompare(configTables[i], DEFAULT_SETTINGS, false) then
        io_persistence.store(defaultSettingsFileName, MOD_ID, DEFAULT_SETTINGS)
        configTables[i] = io_persistence.load(defaultSettingsFileName, MOD_ID)
    end
end

-- Removes this table from memory.
DEFAULT_SETTINGS = nil
]]

-- Function that will create all of the display bars for a given ISOPlayer.
local function createUI(playerIndex, isoPlayer)
    
    -- Make sure this is a local player only.
    if not isoPlayer:isLocalPlayer() then return end
    
    frameRate = getPerformance():getFramerate()
    tickRate = 60 + frameRate
    
    -- Split-screen support
    local xOffset = getPlayerScreenLeft(playerIndex)
    local yOffset = getPlayerScreenTop(playerIndex)
    
    local coopNum = playerIndex + 1
    
    local isAlreadySpawned = false
    for k, v in pairs(playerIndices) do
        if playerIndices[k] == (coopNum) then
            isAlreadySpawned = true
            break
        end
    end
    if not isAlreadySpawned then table.insert(playerIndices, coopNum) end
    
    if playerIndices[1] == coopNum then
        configFileLocations[coopNum] = configFileName
    elseif playerIndices[2] == coopNum then
        configFileLocations[coopNum] = configFileName .. " P2.lua"
    elseif playerIndices[3] == coopNum then
        configFileLocations[coopNum] = configFileName .. " P3.lua"
    elseif playerIndices[4] == coopNum then
        configFileLocations[coopNum] = configFileName .. " P4.lua"
    else
        configFileLocations[coopNum] = configFileName .. " P_wildcard.lua"
    end
    
    configTables[coopNum] = io_persistence.load(defaultSettingsFileName, MOD_ID)
    
    if not deepcompare(configTables[coopNum], DEFAULT_SETTINGS, false) then
        io_persistence.store(defaultSettingsFileName, MOD_ID, DEFAULT_SETTINGS)
        configTables[coopNum] = io_persistence.load(defaultSettingsFileName, MOD_ID)
    end
    
    --if isoPlayer:isLocalPlayer() then numOfLocalClients = numOfLocalClients + 1 end
    --numOfLocalClients = numOfLocalClients + 1
    --local coopNum = numOfLocalClients
    --local listOfPlayers = getPlayer():getPlayers()
    --print(type(listOfPlayers))
    --for k, v in ipairs(listOfPlayers) do
    --    numOfLocalClients = numOfLocalClients + 1
    --end
    --print(listOfPlayers)
    --numOfLocalClients = math.floor(listOfPlayers:size())
    
    
    -- MoodletThresholdTables
    local moodletThresholdTables = getMoodletThresholdTables()
    
    
    --===============================================================================
    -- Get/Setup all configuration settings from the config file.
    local t_restored = io_persistence.load(configFileLocations[coopNum], MOD_ID)
    
    if not compare_and_insert(configTables[coopNum], t_restored, true) then
        io_persistence.store(configFileLocations[coopNum], MOD_ID, t_restored)
    end

    if t_restored then 
        configTables[coopNum] = t_restored 
    else 
        configTables[coopNum] = recreateConfigFiles(coopNum)
    end
    
    -- Prevents Display bars from covering player 2-3-4's inventory and other options.
    --[[if coopNum >= 2 then
        for k, _ in pairs(configTables[coopNum]) do 
            if type(configTables[coopNum][k]) == "table" then
                if k ~= "menu" then 
                    print(k .. " " .. tostring(k ~= "menu"))
                    configTables[coopNum][k]["alwaysBringToTop"] = false
                end
            end
        end 
    end]]
    
    --==================================
    -- Create Display Bars
    displayBars[playerIndex] = {}
    
    --[[ === REFERENCE ===
    
    someBar must be created above the ContextMenu. local someBar = {}
    someBar = GenericMiniDisplayBar:new(
                    idName, fileSaveLocation,  
                    playerIndex, isoPlayer, coopNum, 
                    configTable, xOffset, yOffset, 
                    bChild, 
                    valueFunction, 
                    colorFunction, useColorFunction,
                    moodletThresholdTable)
    ]]
    
    local idName = "menu"
    if barMenu[playerIndex] then barMenu[playerIndex]:close() end
    barMenu[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    function(tIsoPlayer) 
                        if tIsoPlayer:isDead() then return -1 else return 1 end 
                    end,
                    nil, false,
                    nil)
    barMenu[playerIndex]:initialise()
    barMenu[playerIndex]:addToUIManager()
    
    local idName = "hp"
    if barHP[playerIndex] then barHP[playerIndex]:close() end
    barHP[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getHealth,
                    getColorHP, true,
                    nil)
                    --moodletThresholdTables[idName])
    barHP[playerIndex]:initialise()
    barHP[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barHP[playerIndex])
    
    local idName = "hunger"
    if barHunger[playerIndex] then barHunger[playerIndex]:close() end
    barHunger[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getHunger,
                    getColorHunger, true,
                    moodletThresholdTables[idName])
    barHunger[playerIndex]:initialise()
    barHunger[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barHunger[playerIndex])
    
    local idName = "thirst"
    if barThirst[playerIndex] then barThirst[playerIndex]:close() end
    barThirst[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getThirst,
                    getColorThirst, true,
                    moodletThresholdTables[idName])
    barThirst[playerIndex]:initialise()
    barThirst[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barThirst[playerIndex])
    
    local idName = "endurance"
    if barEndurance[playerIndex] then barEndurance[playerIndex]:close() end
    barEndurance[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getEndurance,
                    getColorEndurance, true,
                    moodletThresholdTables[idName])
    barEndurance[playerIndex]:initialise()
    barEndurance[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barEndurance[playerIndex])
    
    local idName = "fatigue"
    if barFatigue[playerIndex] then barFatigue[playerIndex]:close() end
    barFatigue[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getFatigue,
                    getColorFatigue, true,
                    moodletThresholdTables[idName])
    barFatigue[playerIndex]:initialise()
    barFatigue[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barFatigue[playerIndex])
    
    local idName = "boredomlevel"
    if barBoredomLevel[playerIndex] then barBoredomLevel[playerIndex]:close() end
    barBoredomLevel[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getBoredomLevel,
                    getColorBoredomLevel, true,
                    moodletThresholdTables[idName])
    barBoredomLevel[playerIndex]:initialise()
    barBoredomLevel[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barBoredomLevel[playerIndex])
    
    local idName = "unhappynesslevel"
    if barUnhappynessLevel[playerIndex] then barUnhappynessLevel[playerIndex]:close() end
    barUnhappynessLevel[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getUnhappynessLevel,
                    getColorUnhappynessLevel, true,
                    moodletThresholdTables[idName])
    barUnhappynessLevel[playerIndex]:initialise()
    barUnhappynessLevel[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barUnhappynessLevel[playerIndex])
    
    local idName = "temperature"
    if barTemperature[playerIndex] then barTemperature[playerIndex]:close() end
    barTemperature[playerIndex] = GenericMiniDisplayBar:new(
                    idName, configFileLocations[coopNum], 
                    playerIndex, isoPlayer, coopNum, 
                    configTables[coopNum], xOffset, yOffset, 
                    nil, 
                    getTemperature,
                    getColorTemperature, true,
                    moodletThresholdTables[idName])
    barTemperature[playerIndex]:initialise()
    barTemperature[playerIndex]:addToUIManager()
    table.insert(displayBars[playerIndex], barTemperature[playerIndex])
    
    
    -- Make sure bars are all toggled correctly when new bars are added.
    for _, bar in pairs(displayBars[playerIndex]) do
        if bar then 
            if barHP[playerIndex].moveWithMouse ~= bar.moveWithMouse then
                toggleMovable(bar) end
            if barHP[playerIndex].resizeWithMouse ~= bar.resizeWithMouse then
                toggleResizeable(bar) end
            if barHP[playerIndex].alwaysBringToTop ~= bar.alwaysBringToTop then
                toggleAlwaysBringToTop(bar) end
            if barHP[playerIndex].showMoodletThresholdLines ~= bar.showMoodletThresholdLines then
                toggleMoodletThresholdLines(bar) end
            if barHP[playerIndex].isCompact ~= bar.isCompact then
                toggleCompact(bar) end
        end
    end
    
end

Events.OnGameBoot.Add(OnBootGame)

Events.OnCreatePlayer.Add(createUI)
Events.OnDisconnect.Add(OnLocalPlayerDisconnect)
--Events.OnPlayerDeath.Add(OnLocalPlayerDeath)

Events.OnRenderTick.Add(onTickHP)
Events.OnPlayerUpdate.Add(onPlayerUpdateCheckBodyDamage)
