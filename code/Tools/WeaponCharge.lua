local _addon = WYK_Toolbar

local weaponChargePct = function( eslot )
	local link = GetItemLink( 0, eslot )
	if link == nil or link == "" then return 999 end
	if not IsItemChargeable( 0, eslot ) then return 999 end
	local cc = GetItemLinkNumEnchantCharges(link)
	local mc = GetItemLinkMaxEnchantCharges(link)
	if cc and mc then
		return cc / mc
	else
		return 999
	end
end

_addon.Feature.Toolbar.GetWeaponCharge = function()
	local ico = "/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds"
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["weaponcharge_icon"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	if useIcon then
		local o = wykkydsToolbar.Tools[_addon.G.BAR_WEAPONCHARGE].Control
		if o.Icon == nil then 
			o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); 
			o.Icon:SetTexture( ico ) 
		end
		o.IconSize = 24
		o.BufferSize = 22 * toolScale
		if not o.UseIcon then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 1 )
			o.Icon:SetHidden(false)
			local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
			o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
			o:ClearAnchors()
			o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
		end
		o.UseIcon = true
	else
		local o = wykkydsToolbar.Tools[_addon.G.BAR_WEAPONCHARGE].Control
		if o.UseIcon == true then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 1 )
			o.Icon:SetHidden(true)
			if o.PreviousAnchor ~= nil then
				o:ClearAnchors()
				o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
			end
			o.PreviousAnchor = nil
		end
		o.UseIcon = false
	end
	return
		weaponChargePct( _addon.GLOBAL.EquipSlotBagSlot["EQUIP_SLOT_MAIN_HAND"] ) .. "#" ..
		weaponChargePct( _addon.GLOBAL.EquipSlotBagSlot["EQUIP_SLOT_OFF_HAND"] ) .. "#" ..
		weaponChargePct( _addon.GLOBAL.EquipSlotBagSlot["EQUIP_SLOT_BACKUP_MAIN"] ) .. "#" ..
		weaponChargePct( _addon.GLOBAL.EquipSlotBagSlot["EQUIP_SLOT_BACKUP_OFF"] )
end