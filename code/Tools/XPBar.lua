local _addon = WYK_Toolbar
--local hasMaxVR
--local maxVRLevel = GetMaxVeteranRank()

_addon.Feature.Toolbar.GetXPBar = function()
    local xp, xplvl
    if IsUnitChampion('player') then
		rank = GetPlayerChampionPointsEarned()
           xp, xplvl = GetPlayerChampionXP(), GetNumChampionXPInChampionPoint(rank)        
    else
        xp, xplvl =  GetUnitXP('player'), GetUnitXPMax('player')
    end
    if xplvl == nil or tonumber(xplvl) == 0 then return 1 end
    return _addon:Round((xp / xplvl), 2)
end
