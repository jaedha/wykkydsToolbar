local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetSoulGems = function()
    local style = _addon:GetOrDefault( "Empty / Full", _addon.Settings["soulgem_mode"])
    local useIcon = _addon:GetOrDefault( true, _addon.Settings["soulgem_icon"] )
    local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
		local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
    local retVal, c = "", {215/255,213/255,205/255,1}
    local name, icon, icon2, stackCount = "", "", "", 0
    local myLevel = GetUnitEffectiveLevel("player")
    local emptyCount, fullCount = 0, 0
    
    local fullColor = "00FF00"
    if useWhiteText then fullColor = "FFFFFF"; end
    
    name, icon, stackCount = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, myLevel, true); emptyCount = stackCount;
    name, icon2, stackCount = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, myLevel, true); fullCount = stackCount;
    if style == "Empty / Full" then retVal = emptyCount .. " / ".. "|c"..fullColor..fullCount.."|r"
    elseif style == "Empty" then retVal = emptyCount
    elseif style == "Full" then retVal = "|c"..fullColor..fullCount.."|r" end
    if (icon2 ~= "" and icon2 ~= nil) and icon2 ~= "/esoui/art/icons/icon_missing.dds" then icon = icon2 end
	if emptyCount == 0 and fullCount == 0 then icon = "/esoui/art/icons/soulgem_001_empty.dds" end
    if useIcon then
        local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GEMS].Control
        if o.Icon == nil then o.Icon = _addon.Feature.Toolbar.MakeSpacerControl( o ); end
        o.Icon:SetTexture( icon )
        o.IconSize = 17
        o.BufferSize = 22 * toolScale
        if not o.UseIcon then
            o.Icon:SetDimensions( o.IconSize, o.IconSize )
            o.Icon:ClearAnchors()
            o.Icon:SetAnchor( RIGHT, o, LEFT, -8, 0 )
            o.Icon:SetHidden(false)
            local aBool, aPoint, aTarget, aTargetPoint, aX, aY = o:GetAnchor()
            o.PreviousAnchor = {aPoint, aTarget, aTargetPoint, aX, aY}
            o:ClearAnchors()
            o:SetAnchor( aPoint, aTarget, aTargetPoint, aX + o.BufferSize, aY )
        end
        o.UseIcon = true
    else
        local o = wykkydsToolbar.Tools[_addon.G.BAR_TOOL_GEMS].Control
        if o.UseIcon == true then
            o.Icon:SetDimensions( o.IconSize, o.IconSize )
            o.Icon:ClearAnchors()
            o.Icon:SetAnchor( RIGHT, o, LEFT, -8, 0 )
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

    return retVal, c
end