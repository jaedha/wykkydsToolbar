local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetDurability = function()
	local ico = "/esoui/art/ava/ava_resourcestatus_tabicon_defense_inactive.dds"
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["durability_icon"] )
	local useCommas = _addon:GetOrDefault( true, _addon.Settings["durability_commas"])
  local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	
	local cc, nc = {1,1,.76,1}, {1,1,.76,.5}
	local cost = 0; for eslot = 0, GetBagSize(0), 1 do cost = cost + GetItemRepairCost(0, eslot); end
	if cost == 0 then cost = "~"; cc=nc; else 
		if useCommas then cost = _addon:comma_value(cost) end
		cost = cost.." g" 
	end
	
	if useIcon then
		local o = wykkydsToolbar.Tools[_addon.G.BAR_DURABILITY].Control
		if o.Icon == nil then 
			o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); 
			o.Icon:SetTexture( ico ) 
		end
		o.IconSize = 24
		o.BufferSize = 22 * toolScale
		if not o.UseIcon then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -2, 2 )
			o.Icon:SetHidden(false)
			local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
			o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
			o:ClearAnchors()
			o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
		end
		o.UseIcon = true
	else
		local o = wykkydsToolbar.Tools[_addon.G.BAR_DURABILITY].Control
		if o.UseIcon == true then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -2, 2 )
			o.Icon:SetHidden(true)
			if o.PreviousAnchor ~= nil then
				o:ClearAnchors()
				o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
			end
			o.PreviousAnchor = nil
		end
		o.UseIcon = false
	end
    
  if useWhiteText then cc = {1,1,1,1}; end

	return cost, cc
end