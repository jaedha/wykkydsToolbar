local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetHorse = function()
	local style = _addon:GetOrDefault( "Countdown", _addon.Settings["horse_setting"])
	local useIcon = _addon:GetOrDefault( true, _addon.Settings["horse_icon"] )
	local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	local TimeTilMountFeed, TotalTime = nil, nil
	
	for ii = 0, 10, 1 do
		TimeTilMountFeed, TotalTime = GetTimeUntilCanBeTrained(ii)
		if TimeTilMountFeed ~= nil and TotalTime ~= nil then break end
	end
	if useIcon then
		local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_HORSE].Control
		if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); o.Icon:SetTexture( "/esoui/art/mounts/tabicon_mounts_up.dds" ) end
		o.IconSize = 24
		o.BufferSize = 18 * toolScale
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
		local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_HORSE].Control
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
	if TimeTilMountFeed == nil or TotalTime == nil then return "None To Train", { .65, .65, .65, 1 } end
	local r, g, b = _addon:GetColorScale_RedGreenPowerMeter(TimeTilMountFeed, TotalTime, true)
	local retVal, c = "", { r, g, b, 1 }
	local TimeForHuman = _addon:GetMillisecondsToHuman(TimeTilMountFeed, false)
	if TimeTilMountFeed == nil or TotalTime == nil then return retVal, c; end
	local hh, mm, ss = TimeForHuman:match("([^:]+):([^:]+):([^:]+)")
	local hn, mn, sn = tonumber(hh), tonumber(mm), tonumber(ss)
	-- Fancy shows a verbose "cute" adjective for the stage of training during that hour.
	if style == "Fancy" then
		if hn == 19 then retVal = "Learning"
		elseif hn >= 18 then retVal = "Memorizing"
		elseif hn >= 16 then retVal = "Absorbing"
		elseif hn >= 12 then retVal = "Practicing"
		elseif hn >= 8 then retVal = "Studying"
		elseif hn >= 4 then retVal = "Exhausted"
		elseif hn >= 2 then retVal = "Resting"
		elseif hn == 1 then retVal = "Sore"
		else
			if mn >= 30 then retVal = "Stretching"
			elseif mn >= 15 then retVal = "Flexing"
			elseif mn >= 1 then retVal = "Prepping"
			else
				if sn >= 30 then retVal = "Warm Up"
				elseif sn >= 15 then retVal = "Ready"
				else
					retVal = "TRAIN!"
				end
			end
		end
	-- Descriptive shows xx hours left etc ...  instead of countdown
	elseif style == "Descriptive" then
		if hn > 0 then retVal = hh .. " Hours" else
			if mn > 0 then retVal = mm .. " Minutes" else
				if sn > 0 then retVal = ss .. " Seconds" else
					retVal = "TRAIN!"
				end
			end
		end
	-- Countdown shows 00:00:00 style timer
	elseif style == "Countdown" then
		retVal = TimeForHuman
	end
	
	if _addon.Feature.Toolbar.horseTrainingComplete() then
		retVal = _addon.Feature.Toolbar.horseCompleteLabel()
	end
    
	if useWhiteText then c = {1,1,1,1}; end

	return retVal, c
end

-- Horse training complete function (hide or display totals)  - Ravalox
_addon.Feature.Toolbar.horseCompleteLabel = function ()
	local carry, carryMax, stamina, staminaMax, speed, speedMax = GetRidingStats()

	local label = (speed .."/" .. stamina .. "/" .. carry)
	return label
end

_addon.Feature.Toolbar.horseTrainingComplete = function(carry, carryMax, stamina, staminaMax, speed, speedMax)
	if carry == nil or carryMax == nil or stamina == nil or staminaMax == nil or speed == nil or speedMax == nil then
		carry, carryMax, stamina, staminaMax, speed, speedMax = GetRidingStats()
	end

	if carry == carryMax and stamina == staminaMax and speed == speedMax then
		return true
	else
		return false
	end
end