local _addon = WYK_Toolbar

local weaponMeterWidth = 90

_addon._DefaultLabelColor = "|c7FA292"

_addon.Feature.Toolbar.MakeSpacerControl = function(o)	
	return _addon.Frames.__NewImage("wykkydsToolbar_Spacer", o)
		:SetTexture(nil)
		:SetDimensions( 12 * ( _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100 ), 12 * ( _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100 ) )
		:SetHidden(false)
	.__END
end

_addon.Feature.Toolbar.MakeToolControl = function(o, key, t)
	if t == "xp_bar_enabled" then
		return _addon.Feature.Toolbar.ScaledBar( o, "xpBar", {0,0,0,.6}, {.6, 1, .6, .95}, {1, .6, .6, .85}, {.7, .7, 1, .85}, {0,0,.75,.65}, 120, 60, 20, 100 )
	elseif t == "creature_xp_bar_enabled" then
		return _addon.Feature.Toolbar.ScaledBar( o, "specialXPBar", {0,0,0,.6}, {1, 0, 0, .95}, {104/255, 0, 0, .85}, {184/255, 0, 0, .85}, {1,0,0,.65}, 120, 60, 20, 100 )
	elseif t == "weaponcharge_enabled" then
		local ret = _addon.Feature.Toolbar.MultiBar( 4, o, "weaponchargeBar", {0,0,0,.25}, {.65, .65, 1, 1}, {.65, .65, 1, 1}, {.65, .65, 1, 1}, {0,0,0,0}, weaponMeterWidth, 60, 20, 50 )
		ret:HideBar()
		return ret
	else
		return _addon.Frames.__NewLabel("wykkydsToolbarControl", o)
			:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 15 * ( _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100 ), "soft-shadow-thick"))
			:SetColor(215/255,213/255,205/255,1)
			:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["center"])
			:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
			:SetText("")
			:SetHidden(false)
		.__END
	end
end

_addon.Feature.Toolbar.MakeToolbar = function(o)
	local key = o:GetName()
	
	local spacerSetting = _addon:GetOrDefault( "Dot", _addon.Settings["spacer_style"])
	local spacerTexture
	
	if spacerSetting == "Dot" then
		spacerTexture = "/esoui/art/buttons/checkbox_mouseover.dds"
	elseif spacerSetting == "Box" then
		spacerTexture = "/esoui/art/buttons/smoothsliderbutton_up.dds"
	elseif spacerSetting == "Dash" then
		spacerTexture = "/esoui/art/buttons/gamepad/gp_minus.dds"
	elseif spacerSetting == "Horizontal Line" then
		spacerTexture = "/esoui/art/miscellaneous/horizontaldivider_dynamic.dds"
	elseif spacerSetting == "Map Icon" then
		spacerTexture = "/wykkydsToolbar/textures/map.dds"
	elseif spacerSetting == "Vertical Line" then
		spacerTexture = "/wykkydsToolbar/textures/vertical.dds"
	else
		spacerTexture = "/wykkydsToolbar/textures/blank.dds"
	end
	
	if _addon:GetOrDefault( false, _addon.Settings["white_text"] ) then _addon._DefaultLabelColor = "|cFFFFFF" end
	
	for k,t in pairs(o.Tools) do
		if not o.Tools[k].Control then o.Tools[k].Control = _addon.Feature.Toolbar.MakeToolControl(o, key.."_"..t.Name, t.Name) end
	end
	local lastControl = nil
	local barScale = _addon:GetOrDefault( 100, _addon.Settings["scale"])

	for k,t in ipairs(_addon.G.BAR_TOOLS) do
		if _addon.TSetting(t.Tool) ~= nil
		and _addon.TSetting(t.Tool) ~= "Off"
		and _addon.TSetting(t.Tool) ~= false then
			o.Tools[t.Tool].Control:ClearAnchors()
			o.Tools[t.Tool].Control.padding = 0
			if not lastControl then
				o.Tools[t.Tool].Spacer = nil
				if o.Tools[t.Tool].Control.UseIcon then
					o.Tools[t.Tool].Control.PreviousAnchor = { LEFT, o, LEFT, o.Tools[t.Tool].Control.padding, 0 }
					o.Tools[t.Tool].Control:SetAnchor(LEFT, o, LEFT, o.Tools[t.Tool].Control.padding + o.Tools[t.Tool].Control.BufferSize, 0)
				else
					o.Tools[t.Tool].Control:SetAnchor(LEFT, o, LEFT, o.Tools[t.Tool].Control.padding, 0)
				end
			else
				if o.Tools[t.Tool].Spacer == nil then o.Tools[t.Tool].Spacer = _addon.Feature.Toolbar.MakeSpacerControl(o) end
				o.Tools[t.Tool].Spacer:SetTexture(spacerTexture)
				o.Tools[t.Tool].Spacer:ClearAnchors()
				o.Tools[t.Tool].Control.padding = 6
				o.Tools[t.Tool].Spacer:SetHidden(false)
				o.Tools[t.Tool].Spacer:SetAnchor(LEFT, lastControl, RIGHT, o.Tools[t.Tool].Control.padding, 0)
				if o.Tools[t.Tool].Control.UseIcon then
					o.Tools[t.Tool].Control.PreviousAnchor = { LEFT, o.Tools[t.Tool].Spacer, RIGHT, o.Tools[t.Tool].Control.padding, 0 }
					o.Tools[t.Tool].Control:SetAnchor(LEFT, o.Tools[t.Tool].Spacer, RIGHT, o.Tools[t.Tool].Control.padding + o.Tools[t.Tool].Control.BufferSize, 0)
				else
					o.Tools[t.Tool].Control:SetAnchor(LEFT, o.Tools[t.Tool].Spacer, RIGHT, o.Tools[t.Tool].Control.padding, 0)
				end
			end
			lastControl = o.Tools[t.Tool].Control
			if o.Tools[t.Tool].Control ~= nil then o.Tools[t.Tool].Control:SetHidden(false) end
		else
			o.Tools[t.Tool].Spacer = nil
			if o.Tools[t.Tool].Control ~= nil then o.Tools[t.Tool].Control:SetHidden(true) end
		end
	end
	o.UpdateAll()
	_addon:RegisterEvent( EVENT_ZONE_CHANGED, _addon.Feature.Toolbar.zoneUpdate, false )
	_addon:RegisterEvent( EVENT_PLAYER_ACTIVATED, _addon.Feature.Toolbar.zoneUpdate, false )
end

local hideSpacer = function( spacer )
	if spacer ~= nil then
		spacer:SetHidden( true )
		spacer:ClearAnchors()
		spacer:SetAnchor( TOP, GuiRoot, TOP, 0, -10000 )
	end
end

_addon.Feature.Toolbar.Redraw = function()
	local key = "wykkydsToolbar"
	local o = _G[key]
	
	if o == nil then
		_addon.Feature.Toolbar.Create()
		return
	end
	for k,t in ipairs(_addon.G.BAR_TOOLS) do
		hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
	end
	_addon.Feature.Toolbar.MakeToolbar(o)
end

_addon.Feature.Toolbar.GetAnchorPoint = function()
	local setting = _addon:GetOrDefault( "CENTER", _addon.Settings["align_tools"] )
	if setting == "CENTER" then return CENTER end
	if setting == "LEFT" then return TOPLEFT end
	if setting == "RIGHT" then return TOPRIGHT end
end

local BumpCompass = function(windowRenudge)
	local resetpositionofcompass = false
	if not AZ_MOVED_TARGET and not AZ_MOVED_COMPASS then
		if _addon:GetOrDefault( true, _addon.Settings["bump_compass"] ) and (_addon.Feature.Toolbar.IsMoving or windowRenudge) then
			resetpositionofcompass = true
			if wykkydsToolbar:GetTop() <= 80 then
				if ZO_CompassFrame:GetTop() ~= wykkydsToolbar:GetTop() + 60 then
					ZO_CompassFrame:ClearAnchors()
					ZO_CompassFrame:SetAnchor( TOP, GuiRoot, TOP, 0, wykkydsToolbar:GetTop() + 60)
					ZO_TargetUnitFramereticleover:ClearAnchors()
					ZO_TargetUnitFramereticleover:SetAnchor( TOP, GuiRoot, TOP, 0, wykkydsToolbar:GetTop() + 108)
				end
			elseif wykkydsToolbar:GetTop() <= 100 then
					ZO_TargetUnitFramereticleover:ClearAnchors()
					ZO_TargetUnitFramereticleover:SetAnchor( TOP, GuiRoot, TOP, 0, wykkydsToolbar:GetTop() + 40)
			else
				if ZO_CompassFrame:GetTop() ~= 40 then
					ZO_CompassFrame:ClearAnchors()
					ZO_CompassFrame:SetAnchor( TOP, GuiRoot, TOP, 0, 40 )
					ZO_TargetUnitFramereticleover:ClearAnchors()
					ZO_TargetUnitFramereticleover:SetAnchor( TOP, GuiRoot, TOP, 0, 88 )
				end
			end
		elseif resetpositionofcompass then
			ReloadUI()
		end
	end
end

local multiSplit = function( str )
	local out = _addon:string_split( str, "#" )
	local ret = {}
	for k,v in pairs( out ) do
		if v ~= nil and v ~= "999" and v ~= "nil" then
			ret[_addon:GetNextOf(ret)] = tonumber(v) * weaponMeterWidth
		else
			ret[_addon:GetNextOf(ret)] = 999
		end
	end
	return ret
end

local updateAll = function()
	local w = 0
	if _addon:GetOrDefault( false, _addon.Settings["let_leave_screen"] ) ~= true and not _addon.Feature.Toolbar.IsMoving then
		local leftEdge, rightEdge, bottomEdge = GuiRoot:GetLeft(), GuiRoot:GetRight(), GuiRoot:GetBottom()
		local x, y = wykkydsToolbar:GetCenter()
		local gCenterX, gCenterY = GuiRoot:GetCenter()
		if gCenterX ~= nil and gCenterY ~= nil then
			if math.floor(wykkydsToolbar:GetTop()) <= 0 then   -- added "=" 5-21-15  This is the primary check to move compass down if feature is enabled.  Wasnt moving down as top=0
				local anchorPoint, adj = _addon.Feature.Toolbar.GetAnchorPoint(), 0
				if anchorPoint == TOPLEFT then
					adj = wykkydsToolbar:GetLeft()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( TOP, GuiRoot, TOP, x-gCenterX, 0 )
					wykkydsToolbar:SetFrameCoords()
				elseif anchorPoint == TOPRIGHT then
					adj = wykkydsToolbar:GetRight()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( TOP, GuiRoot, TOP, x-gCenterX, 0 )
					wykkydsToolbar:SetFrameCoords()
				else
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( TOP, GuiRoot, TOP, 0, 0 )
					wykkydsToolbar:SetFrameCoords()
				end
				BumpCompass(true)
				_addon.G.Compass_Bumped = 1
			elseif y > bottomEdge then
				local anchorPoint, adj = _addon.Feature.Toolbar.GetAnchorPoint(), 0
				if anchorPoint == TOPLEFT then
					adj = wykkydsToolbar:GetLeft()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( BOTTOM, GuiRoot, BOTTOM, x-gCenterX, 0 )
					wykkydsToolbar:SetFrameCoords()
				elseif anchorPoint == TOPRIGHT then
					adj = wykkydsToolbar:GetRight()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( BOTTOM, GuiRoot, BOTTOM, x-gCenterX, 0 )
					wykkydsToolbar:SetFrameCoords()
				else
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, 0 )
					wykkydsToolbar:SetFrameCoords()
				end
				BumpCompass(true)
				_addon.G.Compass_Bumped = 1
			elseif x < leftEdge then
				wykkydsToolbar:ClearAnchors()
				wykkydsToolbar:SetAnchor( LEFT, GuiRoot, LEFT, 0, y-gCenterY )
				wykkydsToolbar:SetFrameCoords()
				BumpCompass(true)
				_addon.G.Compass_Bumped = 1
			elseif wykkydsToolbar:GetLeft() < leftEdge then
				local anchorPoint, adj = _addon.Feature.Toolbar.GetAnchorPoint(), 0
				if anchorPoint == TOPLEFT then
					d("[Toolbar] IF 4.2")
					adj = wykkydsToolbar:GetLeft()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( LEFT, GuiRoot, LEFT, 0, y-gCenterY )
					wykkydsToolbar:SetFrameCoords()
					BumpCompass(true)
					_addon.G.Compass_Bumped = 1
					d("[Toolbar] Bump3")
				end
			elseif x > rightEdge then
				wykkydsToolbar:ClearAnchors()
				wykkydsToolbar:SetAnchor( RIGHT, GuiRoot, RIGHT, 0, y-gCenterY )
				wykkydsToolbar:SetFrameCoords()
				BumpCompass(true)
				_addon.G.Compass_Bumped = 1
			elseif wykkydsToolbar:GetRight() > rightEdge then
				local anchorPoint, adj = _addon.Feature.Toolbar.GetAnchorPoint(), 0
				if anchorPoint == TOPRIGHT then
					adj = wykkydsToolbar:GetRight()
					wykkydsToolbar:ClearAnchors()
					wykkydsToolbar:SetAnchor( RIGHT, GuiRoot, RIGHT, 0, y-gCenterY )
					wykkydsToolbar:SetFrameCoords()
				end
				BumpCompass(true)
				_addon.G.Compass_Bumped = 1
			else -- unbump compass if all above tests fail (means someone moved the bar down from the top of the screen)
				if _addon.G.Compass_Bumped ~= 0 then
					_addon.G.Compass_Bumped = 0
					ZO_CompassFrame:SetAnchor(9,GuiRoot,nil,-630,40)
				end
			end
		end
	else -- unbump compass if all above tests fail (means someone moved the bar down from the top of the screen)
		if _addon.G.Compass_Bumped ~= 0 then
			_addon.G.Compass_Bumped = 0
			ZO_CompassFrame:SetAnchor(9,GuiRoot,nil,-630,40)
		end
	end
	BumpCompass()
	local scale = ( _addon:GetOrDefault( 100, _addon.Settings["scale"]) / 100 )
	for k,t in ipairs(_addon.G.BAR_TOOLS) do
		if wykkydsToolbar.Tools[t.Tool].Spacer ~= nil then
			wykkydsToolbar.Tools[t.Tool].Spacer:SetDimensions( 12 * scale, 12 * scale )
		end
		if wykkydsToolbar.Tools[t.Tool].Control ~= nil then
			if t.Tool == _addon.G.BAR_TOOL_XPBar then
				wykkydsToolbar.Tools[t.Tool].Control:SetScale( scale )
			elseif t.Tool == _addon.G.BAR_TOOL_SpecialWorldXPBar then
				wykkydsToolbar.Tools[t.Tool].Control:SetScale( scale )
			else
				if wykkydsToolbar.Tools[t.Tool].Control.Icon ~= nil then
					wykkydsToolbar.Tools[t.Tool].Control.Icon:SetScale( scale )
				end
				if wykkydsToolbar.Tools[t.Tool].Control.SetFont ~= nil then
					wykkydsToolbar.Tools[t.Tool].Control:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 15 * scale, "soft-shadow-thick"))
				end
			end
		end
	end
	local iPad = 4
	w = 0
	local sCount, tCount = 0, 0
	for k,t in ipairs(_addon.G.BAR_TOOLS) do
		if wykkydsToolbar.Tools[t.Tool].Control == nil then
			iPad = 0
		else
			iPad = wykkydsToolbar.Tools[t.Tool].Control.padding or 0
		end
		if t.Tool == _addon.G.BAR_TOOL_XPBar then
			local newPct = 120 * ( t.Method() or .6 )
			if wykkydsToolbar.Tools[t.Tool].Control ~= nil then
				if _addon.TSetting(t.Tool) then
					wykkydsToolbar.Tools[t.Tool].Control:ShowBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( false )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( newPct )
					if wykkydsToolbar.Tools[t.Tool].Spacer ~= nil then sCount = sCount + 1
						wykkydsToolbar.Tools[t.Tool].Spacer:SetHidden( false )
						w = w + wykkydsToolbar.Tools[t.Tool].Spacer:GetWidth() + iPad;
					end
					w = w + wykkydsToolbar.Tools[t.Tool].Control:GetWidth() + iPad; tCount = tCount + 1
				else
					hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
					wykkydsToolbar.Tools[t.Tool].Control:HideBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( true )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( 0 )
				end
			else
				hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
			end
		elseif t.Tool == _addon.G.BAR_TOOL_SpecialWorldXPBar then
			local newPct = 120 * ( t.Method() or .6 )
			if wykkydsToolbar.Tools[t.Tool].Control ~= nil then
				if _addon.TSetting(t.Tool) ~= nil and _addon.TSetting(t.Tool) ~= false and _addon.TSetting(t.Tool) ~= "Off" then
					wykkydsToolbar.Tools[t.Tool].Control:ShowBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( false )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( newPct )
					if wykkydsToolbar.Tools[t.Tool].Spacer ~= nil then sCount = sCount + 1
						wykkydsToolbar.Tools[t.Tool].Spacer:SetHidden( false )
						w = w + wykkydsToolbar.Tools[t.Tool].Spacer:GetWidth() + iPad;
					end
					w = w + wykkydsToolbar.Tools[t.Tool].Control:GetWidth() + iPad; tCount = tCount + 1
				else
					hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
					wykkydsToolbar.Tools[t.Tool].Control:HideBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( true )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( 0 )
				end
			else
				hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
			end
		elseif t.Tool == _addon.G.BAR_WEAPONCHARGE then
			local pcts = multiSplit( t.Method() or "999#999#999#999" )
			if wykkydsToolbar.Tools[t.Tool].Control ~= nil then
				if _addon.TSetting(t.Tool) then
					wykkydsToolbar.Tools[t.Tool].Control:ShowBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( false )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( pcts )
					if wykkydsToolbar.Tools[t.Tool].Spacer ~= nil then sCount = sCount + 1
						wykkydsToolbar.Tools[t.Tool].Spacer:SetHidden( false )
						w = w + wykkydsToolbar.Tools[t.Tool].Spacer:GetWidth() + iPad;
					end
					w = w + wykkydsToolbar.Tools[t.Tool].Control:GetWidth() + iPad; tCount = tCount + 1
					if wykkydsToolbar.Tools[t.Tool].Control.UseIcon then
						w = w + ( wykkydsToolbar.Tools[t.Tool].Control.BufferSize );
					end
				else
					hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
					wykkydsToolbar.Tools[t.Tool].Control:HideBar()
					wykkydsToolbar.Tools[t.Tool].Control:SetHidden( true )
					wykkydsToolbar.Tools[t.Tool].Control:SetPct( multiSplit( "999#999#999#999") )
				end
			else
				hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
			end
		else
			local txt, c = t.Method()
			if wykkydsToolbar.Tools[t.Tool].Control ~= nil then
				wykkydsToolbar.Tools[t.Tool].Control:SetText(txt)
				wykkydsToolbar.Tools[t.Tool].Control:SetColor(c[1],c[2],c[3],c[4])
				if _addon.TSetting(t.Tool) ~= nil and _addon.TSetting(t.Tool) ~= false and _addon.TSetting(t.Tool) ~= "Off" then
					if wykkydsToolbar.Tools[t.Tool].Spacer ~= nil then sCount = sCount + 1
						wykkydsToolbar.Tools[t.Tool].Spacer:SetHidden( false )
						w = w + wykkydsToolbar.Tools[t.Tool].Spacer:GetWidth() + iPad;
					end
					w = w + wykkydsToolbar.Tools[t.Tool].Control:GetWidth() + iPad; tCount = tCount + 1
					if wykkydsToolbar.Tools[t.Tool].Control.UseIcon then
						w = w + ( wykkydsToolbar.Tools[t.Tool].Control.BufferSize );
					end
				else
					hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
				end
			else
				hideSpacer( wykkydsToolbar.Tools[t.Tool].Spacer )
			end
		end
	end
	wykkydsToolbar:SetDimensions(w, 20 * scale)
end

_addon.Feature.Toolbar.Create = function()
	local groupTimers =  _addon:GetOrDefault( true, _addon.Settings["timerGroup"])
	local hideHorse = _addon:GetOrDefault( false, _addon.Settings["horse_trainFull"])
	local horseComplete = _addon.Feature.Toolbar.horseTrainingComplete()
	local hideWorldXP = _addon:GetOrDefault( false, _addon.Settings["world_xp_autohide"])	
	local indexWorldXP = _addon.Feature.Toolbar.SpecialWorldIndex()
	
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_TIME, 	Method = _addon.Feature.Toolbar.GetTime })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_FPS, 	Method = _addon.Feature.Toolbar.GetFramesPerSecond })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_PINGRATE, 	Method = _addon.Feature.Toolbar.GetLatency })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_ZONE, 	Method = _addon.Feature.Toolbar.GetZone })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_NAME, 	Method = _addon.Feature.Toolbar.GetUnit_Name })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_RACE, 	Method = _addon.Feature.Toolbar.GetUnit_Race })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_CLASS, 	Method = _addon.Feature.Toolbar.GetUnit_Class })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_LEVEL, 	Method = _addon.Feature.Toolbar.GetUnit_Level })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_XPBar, 	Method = _addon.Feature.Toolbar.GetXPBar })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_XP, 	Method = _addon.Feature.Toolbar.GetXP })
	if not (hideWorldXP and indexWorldXP == 0) then
		table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_SpecialWorldXPBar, 	Method = _addon.Feature.Toolbar.GetSpecialWorldXPBar })
	end
	if not groupTimers then
		if not (hideHorse and horseComplete) then
			table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_HORSE, 	Method = _addon.Feature.Toolbar.GetHorse })
		end
	end
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_BACKPACK, 	Method = _addon.Feature.Toolbar.GetBackpackDetails })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_BANK, 	Method = _addon.Feature.Toolbar.GetBankDetails })
	
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_AP, 	Method = _addon.Feature.Toolbar.GetAP })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_CROWNS, 	Method = _addon.Feature.Toolbar.GetCrowns })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_CROWN_GEMS, 	Method = _addon.Feature.Toolbar.GetCrownGems })	
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_EVENT_TICKETS, 	Method = _addon.Feature.Toolbar.GetEventTickets })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_GOLD, 	Method = _addon.Feature.Toolbar.GetMoney })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_GEMS, 	Method = _addon.Feature.Toolbar.GetSoulGems })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_TELVAR, 	Method = _addon.Feature.Toolbar.GetTelVar })	
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_XMUTE, 	Method = _addon.Feature.Toolbar.GetXMute })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_WRITS, 	Method = _addon.Feature.Toolbar.GetWrits })
	
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_DURABILITY, 	Method = _addon.Feature.Toolbar.GetDurability })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_WEAPONCHARGE,Method = _addon.Feature.Toolbar.GetWeaponCharge })
	if groupTimers then
		if not (hideHorse and horseComplete) then
			table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_HORSE, 	Method = _addon.Feature.Toolbar.GetHorse })
		end
	end
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_SMITH, 	Method = _addon.Feature.Toolbar.GetSmith })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_WOOD, 	Method = _addon.Feature.Toolbar.GetWood })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_CLOTH, 	Method = _addon.Feature.Toolbar.GetCloth })
	table.insert(_addon.G.BAR_TOOLS, { Tool = _addon.G.BAR_TOOL_JEWEL,  Method = _addon.Feature.Toolbar.GetJewel })	

	local key = "wykkydsToolbar"
	local o = _G[key]

	if o == nil then o = _addon.Frames.__NewTopLevel(key)
		:SetAnchor(_addon.Feature.Toolbar.GetAnchorPoint(), GuiRoot, _addon.Feature.Toolbar.GetAnchorPoint(), _addon:GetOrDefault( 0, _addon.Settings["ShiftX"] ), _addon:GetOrDefault( 0, _addon.Settings["ShiftY"] ))
		:SetDimensions(1000,20)
		:SetMovable(not _addon:GetOrDefault( false, _addon.Settings["lock_in_place"] ))
		:SetMouseEnabled(not _addon:GetOrDefault( false, _addon.Settings["lock_in_place"] ))
		:SetClampedToScreen( true )
		:SetHidden( false )
	.__END
	end
	o.bg = _addon.Frames.__NewBackdrop(key.."BG", o)
		:SetAnchor(TOPLEFT, o, TOPLEFT, -2, -2)
		:SetAnchor(BOTTOMRIGHT, o, BOTTOMRIGHT, 2, 2)
		:SetCenterColor(0.1,0.1,0.1,.5)
		:SetEdgeColor(0,0,0,1)
		:SetEdgeTexture("", 8, 1, 1)
		:SetHidden(not _addon:GetOrDefault( false, _addon.Settings["enable_background"] ))
	.__END
	o.ScrollingWindow = _addon.Frames.__NewTopLevel(key.."scrollWindow")
		:SetDimensions(320,260)
		:SetHidden(false)
		:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
	.__END
	o.ScrollingText = _addon.Frames.__NewLabel(key.."scrollText", o.ScrollingWindow)
		:SetFont("ZoFontGame")
		:SetColor(1,1,1,1)
		:SetText("")
		:SetAnchor(BOTTOMLEFT,tlsc,BOTTOMLEFT,-200,0)
		:SetHidden(false)
	.__END
	o.SetFrameCoords = function(self)
		local setting = _addon.Feature.Toolbar.GetAnchorPoint()
		local lockCenter = _addon:GetOrDefault( true, _addon.Settings["lock_horizontal"] )
		local x, y = 0, 0
		if setting == CENTER then
			local addOnX, addOnY = self:GetCenter()
			local guiRootX, guiRootY = GuiRoot:GetCenter()
			x = addOnX - guiRootX
			y = addOnY - guiRootY
			if lockCenter then x = 0 end
		else
			y = self:GetTop()
			if setting == TOPLEFT then x = self:GetLeft()
			else x = self:GetRight() - GuiRoot:GetRight() end
		end
		_addon.Settings["ShiftX"] = x
		_addon.Settings["ShiftY"] = y
		self:ClearAnchors()
		self:SetAnchor(_addon.Feature.Toolbar.GetAnchorPoint(), GuiRoot, _addon.Feature.Toolbar.GetAnchorPoint(), x, y)
	end
	o:SetFrameCoords()
	o.IsMoving = false
	o:SetHandler("OnMoveStart", function(self) self.IsMoving = true end)
	o:SetHandler("OnMoveStop", function(self) self:SetFrameCoords(); self.IsMoving = false; end)

	o.Tools = {
		[_addon.G.BAR_TOOL_BACKPACK] = { Name = "bag_setting", Control = nil },
		[_addon.G.BAR_TOOL_BANK] = { Name = "bank_setting", Control = nil },
		[_addon.G.BAR_TOOL_FPS] = { Name = "fps_enabled", Control = nil },
		[_addon.G.BAR_PINGRATE] = { Name = "latency_enabled", Control = nil },
		[_addon.G.BAR_TOOL_TIME] = { Name = "clock_type", Control = nil },
		[_addon.G.BAR_TOOL_ZONE] = { Name = "zone_enabled", Control = nil },
		[_addon.G.BAR_TOOL_GOLD] = { Name = "gold_mode", Control = nil },
		[_addon.G.BAR_TOOL_WRITS] = { Name = "writs_mode", Control = nil },
		[_addon.G.BAR_TOOL_XMUTE] = { Name = "xmute_setting", Control = nil },
		[_addon.G.BAR_TOOL_EVENT_TICKETS] = { Name = "eventtickets_setting", Control = nil },
		[_addon.G.BAR_TOOL_TELVAR] = { Name = "telvar_mode", Control = nil },		
		[_addon.G.BAR_TOOL_AP] = { Name = "ap_setting", Control = nil },
		[_addon.G.BAR_TOOL_CROWNS] = { Name = "crowns_setting", Control = nil },		
		[_addon.G.BAR_TOOL_CROWN_GEMS] = { Name = "crowngems_mode", Control = nil },		
		[_addon.G.BAR_TOOL_XP] = { Name = "xpvp_enabled", Control = nil },
		[_addon.G.BAR_TOOL_XPBar] = { Name = "xp_bar_enabled", Control = nil },
		--[_addon.G.BAR_TOOL_SpecialWorldXPBar] = { Name = "creature_xp_bar_enabled", Control = nil },
		[_addon.G.BAR_TOOL_NAME] = { Name = "player_name_enabled", Control = nil },
		[_addon.G.BAR_TOOL_RACE] = { Name = "player_race_enabled", Control = nil },
		[_addon.G.BAR_TOOL_CLASS] = { Name = "player_class_enabled", Control = nil },
		[_addon.G.BAR_TOOL_LEVEL] = { Name = "level_enabled", Control = nil },
		[_addon.G.BAR_TOOL_GEMS] = { Name = "soulgem_setting", Control = nil },
		[_addon.G.BAR_TOOL_HORSE] = { Name = "horse_setting", Control = nil },
		[_addon.G.BAR_TOOL_SMITH] = { Name = "rt_smithing", Control = nil },
		[_addon.G.BAR_TOOL_WOOD] = { Name = "rt_wood", Control = nil },
		[_addon.G.BAR_TOOL_JEWEL] = { Name = "rt_jewel", Control = nil },
		[_addon.G.BAR_TOOL_CLOTH] = { Name = "rt_clothing", Control = nil },
		[_addon.G.BAR_DURABILITY] = { Name = "durability_enabled", Control = nil },
		[_addon.G.BAR_WEAPONCHARGE] = { Name = "weaponcharge_enabled", Control = nil },
	}

	--Demiknight: Need to only add this bar if turned on otherwise the bar appears in the middle of the screen.
	if not (hideWorldXP and indexWorldXP == 0) then
		o.Tools[_addon.G.BAR_TOOL_SpecialWorldXPBar] = { Name = "creature_xp_bar_enabled", Control = nil }
	end
		
	o.UpdateAll = function() updateAll() end
	BumpCompass(true)
	
	if _addon:GetOrDefault(true, _addon.Settings["hide_in_dialog"]) then
		local fragment = ZO_HUDFadeSceneFragment:New(o, nil, 0)
		HUD_SCENE:AddFragment(fragment)
		HUD_UI_SCENE:AddFragment(fragment)
	end
	
	_addon.Feature.Toolbar.MakeToolbar(o)
end

_addon.Feature.Toolbar.ScaledBar = function( parent, name, bg, fg, lowFg, midFg, edge, width, pct, lowPct, midPct )
	local key = parent:GetName()..name
	local o = _G[key]
	if o == nil then o = _addon.Frames.__NewTopLevel(key)
			:SetParent( parent )
			:SetDimensions(width,9)
			:SetHidden(false)
			:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
		.__END
		o.bg = _addon.Frames.__NewBackdrop(key.."BG", o)
			:SetAnchor(TOPLEFT, o, TOPLEFT, -1, -1)
			:SetAnchor(BOTTOMRIGHT, o, BOTTOMRIGHT, 1, 1)
			:SetCenterColor(bg[1], bg[2], bg[3], bg[4], bg[5])
			:SetEdgeColor(edge[1], edge[2], edge[3], edge[4], edge[5])
			:SetEdgeTexture("", 8, 1, 1)
			:SetHidden(false)
		.__END
		o.inner = _addon.Frames.__NewBackdrop(key.."exp", o)
			:SetAnchor(LEFT, o, LEFT, 0, 0)
			:SetCenterColor(fg[1], fg[2], fg[3], fg[4], fg[5])
			:SetEdgeColor(0,0,0,0)
			:SetEdgeTexture("", 8, 1, 1)
			:SetHidden(false)
			:SetDimensions(pct,9)
		.__END
		o.fg = fg
		o.lowFg = lowFg
		o.midFg = midFg
		o.lowPct = lowPct
		o.midPct = midPct
		o.SetPct = function( self, newPct )
			if newPct > self:GetWidth() then newPct = self:GetWidth() end
			self.inner:SetDimensions(newPct,9)
			if newPct <= self.midPct and newPct > self.lowPct then self.inner:SetCenterColor(self.midFg[1], self.midFg[2], self.midFg[3], self.midFg[4], self.midFg[5])
			elseif newPct <= self.lowPct then self.inner:SetCenterColor(self.lowFg[1], self.lowFg[2], self.lowFg[3], self.lowFg[4], self.lowFg[5])
			else self.inner:SetCenterColor(self.fg[1], self.fg[2], self.fg[3], self.fg[4], self.fg[5]) end
		end
		o.HideBar = function( self )
			self:SetHidden( true )
			self.bg:SetHidden( true )
			self.inner:SetHidden( true )
			self:SetAlpha(0)
			self.bg:SetAlpha(0)
			self.inner:SetAlpha(0)
		end
		o.ShowBar = function( self )
			self:SetHidden( false )
			self.bg:SetHidden( false )
			self.inner:SetHidden( false )
			self:SetAlpha(1)
			self.bg:SetAlpha(1)
			self.inner:SetAlpha(1)
		end
	end
	return o
end

_addon.Feature.Toolbar.MultiBar = function( count, parent, name, bg, fg, lowFg, midFg, edge, width, pct, lowPct, midPct )
	local mh = 10
	local offset = .35
	local key = parent:GetName()..name
	local o = _G[key]
	if o == nil then o = _addon.Frames.__NewTopLevel(key)
			:SetParent( parent )
			:SetDimensions(width,mh)
			:SetHidden(false)
			:SetAnchor(TOP,GuiRoot,TOP,0,-10000)
		.__END
		o.MBars = {}
		for nn = 1, count, 1 do
			o.MBars[nn] = _addon.Feature.Toolbar.ScaledBar( parent, name..nn, bg, fg, lowFg, midFg, edge, width, pct, lowPct, midPct )
			o.MBars[nn]:ShowBar()
		end
		o.MBarCount = count
		o.fg = fg
		o.lowFg = lowFg
		o.midFg = midFg
		o.lowPct = lowPct
		o.midPct = midPct
		o.MBarWidth = width
		o.vb = {} 		-- visible bars
		o.vbCount = 0 	-- visible bar count
		o.pct = {}
		o.SetPct = function( self, newPct )
			self.vbCount = 0
			self.vb = {}
			self.pct = {}
			if newPct == nil then
				newPct = {}
				for nn = 1, self.MBarCount, 1 do
					newPct[nn] = width*.6
				end
			end
			for nn = 1, self.MBarCount, 1 do
				local pct = newPct[nn]
				if pct ~= 999 then
					self.vbCount = self.vbCount + 1
					self.vb[self.vbCount] = nn
					self.pct[self.vbCount] = pct
					if pct > self.MBarWidth then pct = self.MBarWidth end
					self.MBars[nn].inner:SetDimensions(pct,mh/self.MBarCount)
					if pct <= self.midPct and pct > self.lowPct then self.MBars[nn].inner:SetCenterColor(self.midFg[1], self.midFg[2], self.midFg[3], self.midFg[4], self.midFg[5])
					elseif pct <= self.lowPct then self.MBars[nn].inner:SetCenterColor(self.lowFg[1], self.lowFg[2], self.lowFg[3], self.lowFg[4], self.lowFg[5])
					else self.MBars[nn].inner:SetCenterColor(self.fg[1], self.fg[2], self.fg[3], self.fg[4], self.fg[5]) end
				else
					self.MBars[nn]:SetDimensions(0,0)
					self.MBars[nn].inner:SetDimensions(0,0)
					self.MBars[nn]:ClearAnchors()
					self.MBars[nn]:SetAnchor( TOPLEFT, self, TOPLEFT, 0, -1*(offset*2) )
				end
			end
			local hh = _addon:Round((mh/ self.vbCount)-(self.vbCount*offset))
			self:HideBar()
			self:ShowBar()
			if self.vbCount > 0 then
				for nn = 1, self.vbCount, 1 do
					local ww = self.MBarWidth
					local wi = self.MBars[self.vb[nn]].inner:GetWidth()
					self.MBars[self.vb[nn]]:SetDimensions(ww,hh)
					self.MBars[self.vb[nn]].bg:SetDimensions(ww,hh)
					self.MBars[self.vb[nn]].bg:ClearAnchors()
					self.MBars[self.vb[nn]].bg:SetAnchor( LEFT )
					self.MBars[self.vb[nn]].inner:SetDimensions(wi,hh)
					self.MBars[self.vb[nn]]:ClearAnchors()
					if nn == 1 then
						self.MBars[self.vb[nn]]:SetAnchor( TOPLEFT, self, TOPLEFT, 0, 0 )
					end
					if nn > 1 then
						self.MBars[self.vb[nn]]:SetAnchor( TOPLEFT, self.MBars[self.vb[nn-1]], BOTTOMLEFT, 0, hh+(offset*2) )
					end
				end
			end
		end
		o.HideBar = function( self )
			self:SetHidden( true )
			for nn = 1, self.MBarCount, 1 do
				self.MBars[nn]:SetDimensions(0,0)
				self.MBars[nn].inner:SetDimensions(0,0)
				self.MBars[nn]:ClearAnchors()
				self.MBars[nn]:SetAnchor( TOPLEFT, self, TOPLEFT, 0, -10000 )
			end
		end
		o.ShowBar = function( self )
			self:SetHidden( false )
			if self.vbCount > 0 then
				for nn = 1, self.vbCount, 1 do
					self.MBars[self.vb[nn]]:SetDimensions(self.MBarWidth,_addon:Round((mh/ self.vbCount)-(self.vbCount*offset)))
					self.MBars[self.vb[nn]].inner:SetDimensions(self.pct[nn] or (self.width * .6),_addon:Round((mh/ self.vbCount)-(self.vbCount*offset)))
					self.MBars[self.vb[nn]]:ClearAnchors()
					if nn == 1 then
						self.MBars[self.vb[nn]]:SetAnchor( TOPLEFT, self, TOPLEFT, 0, -1*(offset*2) )
					end
					if nn > 1 then
						self.MBars[self.vb[nn]]:SetAnchor( TOPLEFT, self.MBars[self.vb[nn-1]], BOTTOMLEFT, 0, ((mh/ self.vbCount) - (self.vbCount*offset))+(offset*2) )
					end
				end
			end
		end
	end
	return o
end
