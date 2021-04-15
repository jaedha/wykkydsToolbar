local _addon = WYK_Toolbar

local fixName = function( str ) if str == nil or str == "" then return "" else return str:gsub("(.-)^.+", "%1") end end

_addon.Feature.Toolbar.GetZone = function()
	local useTitle, title = _addon:GetOrDefault( false, _addon.Settings["zone_title"]), _addon._DefaultLabelColor .. "Zone:|r "
	if not useTitle then title = "" end
	if wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control:GetText() == nil 
	or wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control:GetText() == "" 
	then 
		wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control.Title = title
		return title..fixName(GetPlayerLocationName()), {215/255,213/255,205/255,1}
	else 
		if wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control.Title ~= title then
			wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control.Title = title
			return title..fixName(GetPlayerLocationName()), {215/255,213/255,205/255,1}
		else
			return wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control:GetText(), {215/255,213/255,205/255,1}
		end
	end
end
_addon.Feature.Toolbar.zoneUpdate = function(id, zoneName, subZoneName, newSubzone)
	local useTitle, title = _addon:GetOrDefault( false, _addon.Settings["zone_title"]), _addon._DefaultLabelColor .. "Zone:|r "
	if not useTitle then title = "" end
	if (subZoneName ~= "") then wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control:SetText(title..fixName(subZoneName))
	else wykkydsToolbar.Tools[_addon.G.BAR_TOOL_ZONE].Control:SetText(title..fixName(GetPlayerLocationName())) end
end