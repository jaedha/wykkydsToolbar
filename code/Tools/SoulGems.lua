local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetSoulGems = function()
    local style = _addon:GetOrDefault( "Empty / Full", _addon.Settings["soulgem_mode"])
    local useIcon = _addon:GetOrDefault( true, _addon.Settings["soulgem_icon"] )
    local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
    local toolScale = _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100
    local retVal, c = "", {215/255,213/255,205/255,1}

    local regularFullColor = "FF66FF"
    if useWhiteText then regularFullColor = "FFFFFF"; end

    local crownFullColor = "66DDDD"
    if useWhiteText then crownFullColor = "FFFFFF"; end

    local _, _, emptyCount = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, 50, true);
    local _, icon = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, 50, true);
    local regularFullCount = GetItemLinkStacks('|H1:item:33271:31:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h'); -- regular filled soulgems
    local crownFullCount = GetItemLinkStacks('|H1:item:61080:32:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h'); -- crown soulgems
    local cumulativeFullCount = regularFullCount + crownFullCount;
    if style == "Empty / Full" then
        retVal = emptyCount .. " / " .. "|c" .. regularFullColor .. cumulativeFullCount .. "|r"
        if crownFullCount ~= 0 then
            retVal = retVal .. " (|c" .. crownFullColor .. crownFullCount .. "|r)"
        end
    end
    if style == "Full" then
        retVal = "|c" .. regularFullColor .. cumulativeFullCount .."|r"
        if crownFullCount ~= 0 then
            retVal = retVal .. " (|c" .. crownFullColor .. crownFullCount .. "|r)"
        end
    end
    if style == "Empty" then retVal = emptyCount end
	if emptyCount == 0 and regularFullCount == 0 then icon = "/esoui/art/icons/soulgem_001_empty.dds" end
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
