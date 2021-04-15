local _addon = WYK_Toolbar

local lastNode = nil

_addon.Feature.Toolbar.GetSmith = function()
	return _addon.Feature.Toolbar.GetCraftingValue("rt_smithing", _addon.G.BAR_TOOL_SMITH, CRAFTING_TYPE_BLACKSMITHING, "/esoui/art/icons/servicemappins/servicepin_smithy.dds")
end
_addon.Feature.Toolbar.GetWood = function()
	return _addon.Feature.Toolbar.GetCraftingValue("rt_wood", _addon.G.BAR_TOOL_WOOD, CRAFTING_TYPE_WOODWORKING, "/esoui/art/icons/servicemappins/servicepin_woodworking.dds")
end
_addon.Feature.Toolbar.GetCloth = function()
	return _addon.Feature.Toolbar.GetCraftingValue("rt_clothing", _addon.G.BAR_TOOL_CLOTH, CRAFTING_TYPE_CLOTHIER, "/esoui/art/icons/servicemappins/servicepin_outfitter.dds")
end
_addon.Feature.Toolbar.GetJewel = function()
	return _addon.Feature.Toolbar.GetCraftingValue("rt_jewel", _addon.G.BAR_TOOL_JEWEL, CRAFTING_TYPE_JEWELRYCRAFTING, "/esoui/art/icons/icon_jewelrycrafting_symbol.dds")
end 


_addon.Feature.Toolbar.GetCraftingValue = function(name, toolId, craftType, craftIconPath)
	local result = ""

	local doShow = _addon:GetOrDefault(false, _addon.Settings[name])
	local craftIcons = _addon:GetOrDefault(true, _addon.Settings["rt_icon"])
  local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
	local timerStyles = _addon:GetOrDefault(_addon.G.BAR_STR_COUNTDOWN, _addon.Settings["rt_timers"])
	local timerTarget = _addon:GetOrDefault(_addon.G.BAR_STR_TIME_TO_NEXT_FREE, _addon.Settings["rt_timer_type"])
	local slotDisplay = _addon:GetOrDefault(_addon.G.BAR_STR_OFF, _addon.Settings["rt_slots"])
	local secsMinLeft, secsMinTotal, secsMaxLeft, secsMaxTotal, numSlots, numFreeSlots, icons = _addon.Feature.Toolbar.GetCraftingData(craftType)

	local secsLeft = secsMaxLeft
	local secsTotal = secsMaxTotal
	if _addon.G.BAR_STR_TIME_TO_NEXT_FREE == timerTarget then
		secsLeft = secsMinLeft
		secsTotal = secsMinTotal
	end
	
	local percentDone = 100
	if secsTotal > 0 then percentDone = math.floor(100 * (secsLeft/secsTotal)) end

	local r, g, b = _addon:GetColorScale_RedGreenPowerMeter(secsLeft, secsTotal, true)
	local c = { r, g, b, 1 }

	if not doShow then 
		return result, c;
	end
	if secsLeft == nil or secsTotal == nil then
		return result, c;
	end

	local timeForHuman = _addon:GetMillisecondsToHuman(secsLeft * 1000, false)
	local hh, mm, ss = timeForHuman:match("([^:]+):([^:]+):([^:]+)")
	local hn, mn, sn = tonumber(hh), tonumber(mm), tonumber(ss)
	local dn = math.floor(hn / 24)
	if timerStyles == _addon.G.BAR_STR_FANCY_STUDY then
		if     percentDone < 1  then result = _addon.G.BAR_STR_STUDY_1
		elseif percentDone < 10 then result = _addon.G.BAR_STR_STUDY_2
		elseif percentDone < 20 then result = _addon.G.BAR_STR_STUDY_3
		elseif percentDone < 30 then result = _addon.G.BAR_STR_STUDY_4
		elseif percentDone < 40 then result = _addon.G.BAR_STR_STUDY_5
		elseif percentDone < 50 then result = _addon.G.BAR_STR_STUDY_6
		elseif percentDone == 50 then result = _addon.G.BAR_STR_STUDY_HALF
		elseif percentDone < 60 then result = _addon.G.BAR_STR_STUDY_7
		elseif percentDone < 70 then result = _addon.G.BAR_STR_STUDY_8
		elseif percentDone < 80 then result = _addon.G.BAR_STR_STUDY_9
		elseif percentDone < 90 then result = _addon.G.BAR_STR_STUDY_10
		elseif percentDone < 95 then result = _addon.G.BAR_STR_STUDY_11
		elseif percentDone < 97 then result = _addon.G.BAR_STR_STUDY_12
		elseif percentDone < 98 then result = _addon.G.BAR_STR_STUDY_13
		elseif percentDone < 99 then result = _addon.G.BAR_STR_STUDY_14
		else                         result = _addon.G.BAR_STR_STUDY_DONE
		end
	elseif timerStyles == _addon.G.BAR_STR_PERCENTAGE_DONE then
		result = percentDone .. '%'
	elseif timerStyles == _addon.G.BAR_STR_PERCENTAGE_LEFT then
		result = (100 - percentDone) .. '%'
	elseif timerStyles == _addon.G.BAR_STR_ADAPTIVE then
		if     hn > 0 then result = hh .. ":" .. mm
		elseif mn > 0 then result = mm .. ":" .. ss
		elseif sn > 0 then result = "00:" .. ss
		end
	elseif timerStyles == _addon.G.BAR_STR_ADAPTIVEDAYS then
		if     dn > 0 then result = dn .. "d " .. hh - (24 * dn) .. ":" .. mm
		elseif hn > 0 then result = hh .. ":" .. mm
		elseif mn > 0 then result = mm .. ":" .. ss
		elseif sn > 0 then result = "00:" .. ss
		end
	elseif timerStyles == _addon.G.BAR_STR_DESCRIPTIVE then
		if     hn > 0 then result = hh .. " " .. _addon.G.BAR_STR_HOURS
		elseif mn > 0 then result = mm .. " " .. _addon.G.BAR_STR_MINUTES
		elseif sn > 0 then result = ss .. " " .. _addon.G.BAR_STR_SECONDS
		else               result = _addon.G.BAR_STR_STUDY_DONE	
		end
	elseif timerStyles == _addon.G.BAR_STR_COUNTDOWN then
		result = timeForHuman
	end

	if slotDisplay     == _addon.G.BAR_STR_SLOTS_TOTAL      then  result = _addon._DefaultLabelColor .. numSlots .. "|r " .. result
	elseif slotDisplay == _addon.G.BAR_STR_SLOTS_USED       then  result = _addon._DefaultLabelColor .. (numSlots-numFreeSlots) .. "|r " .. result
	elseif slotDisplay == _addon.G.BAR_STR_SLOTS_FREE       then  result = _addon._DefaultLabelColor .. numFreeSlots .. "|r " .. result
	elseif slotDisplay == _addon.G.BAR_STR_SLOTS_USED_TOTAL then  result = _addon._DefaultLabelColor .. (numSlots-numFreeSlots) .. "/" .. numSlots .. "|r " .. result
	elseif slotDisplay == _addon.G.BAR_STR_SLOTS_FREE_TOTAL then  result = _addon._DefaultLabelColor .. numFreeSlots .. "/" .. numSlots .. "|r " .. result
	end

	if craftIcons then
		local o = wykkydsToolbar.Tools[toolId].Control
		if o.Icon == nil then
			o.Icon = _addon.Feature.Toolbar.MakeSpacerControl(o);
			o.Icon:SetTexture(craftIconPath)
		end
		o.IconSize = 16
		o.BufferSize = 18 * toolScale
		if not o.UseIcon then
			o.Icon:SetDimensions(o.IconSize, o.IconSize)
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor(RIGHT, o, LEFT, -4, 0)
			o.Icon:SetHidden(false)
			local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
			o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
			o:ClearAnchors()
			o:SetAnchor(aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY)
		end
		o.UseIcon = true
	else
		local o = wykkydsToolbar.Tools[toolId].Control
		if o.UseIcon == true then
			o.Icon:SetDimensions(o.IconSize, o.IconSize)
			o.Icon:ClearAnchors()
			o.Icon:SetAnchor(RIGHT, o, LEFT, -4, 0)
			o.Icon:SetHidden(true)
			if o.PreviousAnchor ~= nil then
				o:ClearAnchors()
				o:SetAnchor(o.PreviousAnchor[1], o.PreviousAnchor[2], o.PreviousAnchor[3], o.PreviousAnchor[4], o.PreviousAnchor[5])
			end
			o.PreviousAnchor = nil
		end
		o.UseIcon = false
	end
    
  if useWhiteText then c = {1,1,1,1}; end

	return result, c
end

_addon.Feature.Toolbar.GetCraftingData = function(craftClass)
	local icons = {}
	local secsMinLeft = 0
	local secsMinTotal = 0
	local secsMaxLeft = 0
	local secsMaxTotal = 0

	local numSlots = GetMaxSimultaneousSmithingResearch(craftClass)
	local numResearchLines = GetNumSmithingResearchLines(craftClass)
	local numFreeSlots = numSlots
	for researchLine = 1, numResearchLines do
		local name, icon, numTraits, researchTimeSecs = GetSmithingResearchLineInfo(craftClass, researchLine)
		for researchTrait = 1, numTraits do
			totalTimeSecs, timeLeftSecs = GetSmithingResearchLineTraitTimes(craftClass, researchLine, researchTrait)
			if ((totalTimeSecs ~= nil) and (timeLeftSecs ~= nil)) then
				table.insert(icons, icon)
				numFreeSlots = numFreeSlots - 1
				if timeLeftSecs > secsMaxLeft then
					secsMaxLeft = timeLeftSecs
					secsMaxTotal = totalTimeSecs
				end
				if (timeLeftSecs < secsMinLeft) or (secsMinLeft == 0) then
					secsMinLeft = timeLeftSecs
					secsMinTotal = totalTimeSecs
				end
			end
		end
	end
	return secsMinLeft, secsMinTotal, secsMaxLeft, secsMaxTotal, numSlots, numFreeSlots, icons
end