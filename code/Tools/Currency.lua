local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetAP = function()
	local location = _addon:GetOrDefault( "Character", _addon.Settings["ap_location"])
	location = _addon.Feature.Toolbar.CurrencyLocation(location)

	return _addon.Feature.Toolbar.GetCurrency(CURT_ALLIANCE_POINTS, location, GetAvARankIcon(GetUnitAvARank("player" )), "Alliance Points", _addon.G.BAR_TOOL_AP)
end

_addon.Feature.Toolbar.GetCrowns = function()
	return _addon.Feature.Toolbar.GetCurrency(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT, "/esoui/art/currency/currency_crown.dds", "Crowns", _addon.G.BAR_TOOL_CROWNS)
end

_addon.Feature.Toolbar.GetCrownGems = function()
	return _addon.Feature.Toolbar.GetCurrency(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT, "/esoui/art/currency/currency_crown_gems.dds", "Crown Gems", _addon.G.BAR_TOOL_CROWN_GEMS)
end

_addon.Feature.Toolbar.GetEventTickets = function()
	return _addon.Feature.Toolbar.GetCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT, "/esoui/art/currency/currency_eventticket.dds", "Event Tickets", _addon.G.BAR_TOOL_EVENT_TICKETS)
end

_addon.Feature.Toolbar.GetMoney = function()
	local location = _addon:GetOrDefault( "Character", _addon.Settings["gold_location"])
	location = _addon.Feature.Toolbar.CurrencyLocation(location)

	return _addon.Feature.Toolbar.GetCurrency(CURT_MONEY, location, "/esoui/art/currency/currency_gold.dds", "Gold", _addon.G.BAR_TOOL_GOLD)
end

_addon.Feature.Toolbar.GetTelVar = function()
	local location = _addon:GetOrDefault( "Character", _addon.Settings["telvar_location"])
	location = _addon.Feature.Toolbar.CurrencyLocation(location)

	return _addon.Feature.Toolbar.GetCurrency(CURT_TELVAR_STONES, location, "/esoui/art/currency/currency_telvar.dds", "Tel Var Stones", _addon.G.BAR_TOOL_TELVAR)
end

_addon.Feature.Toolbar.GetXMute = function()
	return _addon.Feature.Toolbar.GetCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT, "/esoui/art/currency/icon_seedcrystal.dds", "Transmute Crystals", _addon.G.BAR_TOOL_XMUTE)
end

_addon.Feature.Toolbar.GetWrits = function()
	local location = _addon:GetOrDefault( "Character", _addon.Settings["writs_location"])
	location = _addon.Feature.Toolbar.CurrencyLocation(location)

	return _addon.Feature.Toolbar.GetCurrency(CURT_WRIT_VOUCHERS, location, "/esoui/art/currency/currency_writvoucher.dds", "Writs", _addon.G.BAR_TOOL_WRITS)
end

_addon.Feature.Toolbar.CurrencyLocation = function(stringLocation)
	if stringLocation == "Account" then return CURRENCY_LOCATION_ACCOUNT end
	if stringLocation == "Bank" then return CURRENCY_LOCATION_BANK end
	if stringLocation == "Character" then return CURRENCY_LOCATION_CHARACTER end
	if stringLocation == "Guild Bank" then return CURRENCY_LOCATION_GUILD_BANK end
end

_addon.Feature.Toolbar.GetCurrency = function(currencyType, currencyLocation, iconTexture, toolTitle, toolType)
	local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	local identifier = _addon:GetOrDefault( "Icon", _addon.Settings["currency_identifier"] )
	local useCommas = _addon:GetOrDefault( true, _addon.Settings["currency_commas"])

	local val, c, title = GetCurrencyAmount(currencyType, currencyLocation), {1,1,.76,1}, ""
	local retVal = ""
	
	if useCommas then
		retVal = _addon:comma_value(val)
	else
		retVal = tostring(val)
	end

	if currencyType == CURT_ALLIANCE_POINTS then
		c = {.65,1,.76,1}
	end

	if currencyType == CURT_EVENT_TICKETS then
		local eventWarn = tonumber(_addon:GetOrDefault( 10, _addon.Settings["eventtickets_warn"]))
		local eventMax = 12
		c = _addon.Feature.Toolbar.ThresholdColor(val, eventWarn, eventMax)
	end
	
	if currencyType == CURT_CHAOTIC_CREATIA then
		local xmuteMode = _addon:GetOrDefault( true, _addon.Settings["xmute_mode"])
		local xmuteWarn = tonumber(_addon:GetOrDefault( 25, _addon.Settings["xmute_warn"]))
		local xmuteMax = 100
		if IsESOPlusSubscriber() then xmuteMax = 200 end
		c = _addon.Feature.Toolbar.ThresholdColor(val, xmuteMax - xmuteWarn, xmuteMax)
		if xmuteMode == "Available / Max" then retVal = retVal .. "|cDFDDDE".." / " .. xmuteMax.."|r" end
	end

	local o = wykkydsToolbar.Tools[toolType].Control
	if identifier == "Title" then
		if o.Icon ~= nil then o.Icon:SetHidden(true) end
		title = _addon._DefaultLabelColor .. toolTitle .. ":|r " 
	elseif identifier == "Icon" then
		if o.Icon == nil then 
			o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); 
			o.Icon:SetTexture(iconTexture) 
		end
		o.IconSize = 17			
		o.BufferSize = 22 * toolScale
		if not o.UseIcon then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 0 )
			o.Icon:SetHidden(false)
			local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
			o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
			o:ClearAnchors()
			o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
		end
		o.UseIcon = true
	else
		if o.UseIcon == true then
			o.Icon:SetDimensions( o.IconSize, o.IconSize )
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor( RIGHT, o, LEFT, -4, 0 )
			o.Icon:SetHidden(true)
			if o.PreviousAnchor ~= nil then
				o:ClearAnchors()
				o:SetAnchor( o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5] )
			end
			o.PreviousAnchor = nil
		end
		o.UseIcon = false
	end
    
	if useWhiteText then c = {1,1,1,1}; end
	return title .. retVal, c
end

_addon.Feature.Toolbar.ThresholdColor = function(val, threshold, maximum)
	if val < threshold then
		return {1,1,.76,1}
	elseif val >= threshold and val < maximum then
		return {1,1,0,1}
	else
		return {1,0,0,1}
	end
end
