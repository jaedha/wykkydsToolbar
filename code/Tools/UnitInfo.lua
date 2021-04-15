local _addon = WYK_Toolbar
--local maxVRLevel = GetMaxVeteranRank()

local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
local cpColor = "C9BC0F"
local unitColor = "C0A27F"
local levelColor = {215/255,213/255,205/255,.85}

local fixName = function( str ) if str == nil or str == "" then return "" else return str:gsub("(.-)^.+", "%1") end end

_addon.Feature.Toolbar.GetUnit_Name = function()
		if _addon:GetOrDefault( false, _addon.Settings["white_text"] ) then
			unitColor = "FFFFFF"
			levelColor = {1,1,1,1}
		end
    return "|c"..unitColor..GetUnitName("player").."|r", levelColor
end

_addon.Feature.Toolbar.GetUnit_Race = function()
		if _addon:GetOrDefault( false, _addon.Settings["white_text"] ) then
			unitColor = "FFFFFF"
			levelColor = {1,1,1,1}
		end
    return "|c"..unitColor..fixName(GetUnitRace("player")).."|r", levelColor
end

_addon.Feature.Toolbar.GetUnit_Class = function()
		if _addon:GetOrDefault( false, _addon.Settings["white_text"] ) then
			unitColor = "FFFFFF"
			levelColor = {1,1,1,1}
		end
    return "|c"..unitColor..fixName(GetUnitClass("player")).."|r", levelColor
end

_addon.Feature.Toolbar.GetUnit_Level = function()
    local useTitle, title = _addon:GetOrDefault( false, _addon.Settings["level_title"]), _addon._DefaultLabelColor .. "Level:|r "
    local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
    
    if not useTitle then title = "" end
    local lvl, c
    
		if useWhiteText then cpColor = "FFFFFF" end
		
    if IsUnitChampion('player') then
        lvl = "|c"..cpColor.."cp|r" .. GetPlayerChampionPointsEarned()
        c = {1,1,.76,.85}
    else
        lvl = GetUnitLevel("player")
        c = levelColor
    end
    
    if useWhiteText then c = {1,1,1,1}; end
    
    return title..lvl, c
end