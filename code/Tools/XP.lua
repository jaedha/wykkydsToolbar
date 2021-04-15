local _addon = WYK_Toolbar
local rank

_addon.Feature.Toolbar.GetXP = function()
    local setting = _addon:GetOrDefault( "Needed %", _addon.Settings["xpvp_enabled"])
    local useTitle = _addon:GetOrDefault( false, _addon.Settings["xpvp_title"] )
    local useCommas = _addon:GetOrDefault( true, _addon.Settings["xpvp_commas"] )
    local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
    local c = {1,1,1,1}
    local xpColor = "A0A0CF"
    local xp, xplvl, title

    if IsUnitChampion('player') then
		-- > Level 50
		
		rank = GetPlayerChampionPointsEarned()
		xp, xplvl, title = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(rank), _addon._DefaultLabelColor .. "CXP:|r "
		-- GetUnitChampionPoints()
		-- GetChampionPointsPlayerProgressionCap()
		-- GetNumChampionXPInChampionPoint(rank)
		-- GetPlayerChampionPointsEarned()
		-- CanUnitGainChampionPoints("player")        
    else
	    --Level 1-49
        xp, xplvl, title =  GetUnitXP('player'), GetUnitXPMax('player'), _addon._DefaultLabelColor .. "XP:|r "
    end

	-- Hmm ... Show Enlightenment?
    
    if useWhiteText then 
    	c = {1,1,1,1}
    	xpColor = "FFFFFF"
    end
	
    if xplvl == nil or tonumber(xplvl) == 0 then return _addon._DefaultLabelColor .. "Max Level|r", c; end
    if not useTitle then title = "" end
    if setting == "Earned / Total" then
        if useCommas then return title .._addon:comma_value(xp).."|c"..xpColor.." / |r".."|c"..xpColor.._addon:comma_value(xplvl).."|r", c;
        else return title ..xp.."|c"..xpColor.." / |r".."|c"..xpColor..xplvl.."|r", c; end
    end
    if setting == "Earned" then
        if useCommas then return title .._addon:comma_value(xp), c;
        else return title ..xp, c; end
    end
    if setting == "Earned % / Total" then
        if useCommas then return title .._addon:Round((xp/xplvl)*100,0).."%|c"..xpColor.." / |r".."|c"..xpColor.._addon:comma_value(xplvl).."|r", c;
        else return title .._addon:Round((xp/xplvl)*100,0).."%|c"..xpColor.." / |r".."|c"..xpColor..xplvl.."|r", c; end
    end
    if setting == "Earned %" then return title .._addon:Round((xp/xplvl)*100,0).."%", c; end
    if setting == "Needed" then
        if useCommas then return title .._addon:comma_value(xplvl - xp).." Needed", c;
        else return title ..(xplvl - xp).." Needed", c; end
    end
    if setting == "Needed %" then return title .._addon:Round(((xplvl - xp)/xplvl)*100,0).."% Needed", c; end
    
    return "", c
end
