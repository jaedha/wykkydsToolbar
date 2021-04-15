local _addon = WYK_Toolbar
local xyzzy

_addon.Feature.Toolbar.GetSpecialWorldXPBar = function()
	skillIndex = _addon.Feature.Toolbar.SpecialWorldIndex()

	if skillIndex == 0 then
		return 0, _addon._DefaultLabelColor .. "Human:|r ", 1;
	end
	worldSkillName, worldSkillLevel = GetSkillLineInfo(SKILL_TYPE_WORLD, skillIndex)
		
	local oldxp, xplvl, xp = GetSkillLineXPInfo(SKILL_TYPE_WORLD, skillIndex)
	if xp == nil or xplvl == nil or oldxp == nil then return 0, _addon._DefaultLabelColor .. "Human:|r ", 1; end
	xp = xp - oldxp
	xplvl = xplvl - oldxp
	local title = _addon._DefaultLabelColor .. worldSkillName .. ":|r "
	if tonumber(xplvl) == 0 then return 1, title, worldSkillLevel; end
	return _addon:Round((xp / xplvl),2), title, worldSkillLevel;
end

_addon.Feature.Toolbar.SpecialWorldIndex = function()
	skillIndex = 0

	if GetNumSkillLines(SKILL_TYPE_WORLD) <= 1 then return 0, _addon._DefaultLabelColor .. "Human:|r ", 1; end

	for xyzzy = 1, GetNumSkillLines(SKILL_TYPE_WORLD) do
		worldSkillName, worldSkillLevel, worldSkillDiscovered = GetSkillLineInfo(SKILL_TYPE_WORLD, xyzzy)
		if (worldSkillName == "Vampire" or worldSkillName == "Werewolf") and worldSkillDiscovered then
			skillIndex = xyzzy;
		end
	end

	return skillIndex
end
