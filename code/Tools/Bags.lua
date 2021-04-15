local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetBackpackDetails = function()
	local bagId = BAG_BACKPACK
	local bagSetting = _addon:GetOrDefault( "Used %", _addon.Settings["bag_setting"])
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["bag_icon"] )
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["bag_title"])
	local bagLow = tonumber(_addon:GetOrDefault( 10, _addon.Settings["bag_low"]))
	local bagMid = tonumber(_addon:GetOrDefault( 25, _addon.Settings["bag_mid"]))
	local bagIcon = "/esoui/art/tooltips/icon_bag.dds"
	local toolType = _addon.G.BAR_TOOL_BACKPACK
	--local bagIcon = "/esoui/art/mainmenu/menubar_inventory_up.dds"
	
	return _addon.Feature.Toolbar.GetBagDetails(bagId, bagSetting, useIcon, useTitle, bagLow, bagMid, bagIcon, toolType)
end

_addon.Feature.Toolbar.GetBankDetails = function()
	local bagId = BAG_BANK
	local bankSetting = _addon:GetOrDefault( "Used / Total", _addon.Settings["bank_setting"])
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["bank_icon"] )
	local useTitle = _addon:GetOrDefault( false, _addon.Settings["bank_title"])
	local bagLow = tonumber(_addon:GetOrDefault( 10, _addon.Settings["bank_low"]))
	local bagMid = tonumber(_addon:GetOrDefault( 25, _addon.Settings["bank_mid"]))
	local bagIcon = "/esoui/art/tooltips/icon_bank.dds"
	local toolType = _addon.G.BAR_TOOL_BANK

	return _addon.Feature.Toolbar.GetBagDetails(bagId, bankSetting, useIcon, useTitle, bagLow, bagMid, bagIcon, toolType)
end

_addon.Feature.Toolbar.GetBagDetails = function(bagId, bagSetting, useIcon, useTitle, bagLow, bagMid, bagIcon, toolType)
	local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	
	local c = {}
	
	local bagSize, bagUsed, bagFree = GetBagSize(bagId), GetNumBagUsedSlots(bagId), GetNumBagFreeSlots(bagId)
	if bagId == BAG_BANK and  IsESOPlusSubscriber() then
		local bagSubSize, bagSubUsed, bagSubFree = GetBagSize(BAG_SUBSCRIBER_BANK), GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK), GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)
		bagSize, bagUsed, bagFree = bagSize + bagSubSize, bagUsed + bagSubUsed, bagFree + bagSubFree
	end
	
	c = {0,1,0,1}
	if tonumber(bagFree) <= bagMid then c = {1,1,0,1} end
	if tonumber(bagFree) <= bagLow then c = {1,0,0,1} end
	
	local retVal = ""
	
	if useTitle then 
		retVal = retVal .. _addon._DefaultLabelColor
		if bagSetting == "Used / Total" then retVal = retVal .. "Bags:|r " .. bagUsed .. "|cDFDDDE".." / " .. bagSize.."|r" end
		if bagSetting == "Used Space" then retVal = retVal .. "Used Space:|r " .. bagUsed end
		if bagSetting == "Used %" then retVal = retVal .. "Used Space:|r " .. _addon:Round((bagUsed / bagSize)*100, 0) .. "%" end
		if bagSetting == "Free Space" then retVal = retVal .. "Free Space:|r " .. bagFree .. " slots" end
		if bagSetting == "Free %" then retVal = retVal .. "Free Space:|r " .. _addon:Round((bagFree / bagSize)*100, 0) .. "%" end
	else
		if bagSetting == "Used / Total" then retVal = retVal .. bagUsed .. "|cDFDDDE".." / " .. bagSize.."|r" end
		if bagSetting == "Used Space" then retVal = retVal .. bagUsed end
		if bagSetting == "Used %" then retVal = retVal .. _addon:Round((bagUsed / bagSize)*100, 0) .. "%" end
		if bagSetting == "Free Space" then retVal = retVal .. bagFree .. " slots" end
		if bagSetting == "Free %" then retVal = retVal .. _addon:Round((bagFree / bagSize)*100, 0) .. "%" end
		if useIcon then
			--local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_BAGS].Control
			--if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); o.Icon:SetTexture( "/esoui/art/mainmenu/menubar_inventory_up.dds" ) end
			local o = wykkydsToolbar.Tools[toolType].Control
			if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); o.Icon:SetTexture( bagIcon ) end
						
			--o.IconSize = 24
			o.IconSize = 16
			
			o.BufferSize = 20 * toolScale
			if not o.UseIcon then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, 0, 0 )
				o.Icon:SetHidden(false)
				local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
				o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
				o:ClearAnchors()
				o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
			end
			o.UseIcon = true
		else
			local o = wykkydsToolbar.Tools[toolType].Control
			--local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_BAGS].Control
			if o.UseIcon == true then
				o.Icon:SetDimensions( o.IconSize, o.IconSize )
				o.Icon:ClearAnchors()
				o.Icon:SetAnchor( RIGHT, o, LEFT, 0, 0 )
				o.Icon:SetHidden(true)
				if o.PreviousAnchor ~= nil then
					o:ClearAnchors()
					o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
				end
				o.PreviousAnchor = nil
			end
			o.UseIcon = false
		end
	end
	
	if useWhiteText then c = {1,1,1,1}; end

	return retVal, c
end