--[[
  * Ravalox' Wykkyd [ Toolbar ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us) & Calia1120
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 3
_addon._v.monthly 	= 2
_addon._v.daily 	= 7
_addon._v.minor 	= 2
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsToolbar"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Toolbar"
_addon.SavedVariableVersion = 4
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["player_name_enabled"] = false,
	["clock_suffix"] = false,
	["bag_setting"] = "Used / Total",
	["weaponcharge_icon"] = true,
	["player_class_enabled"] = false,
	["zone_enabled"] = true,
	["weaponcharge_enabled"] = true,
	["rt_smithing"] = false,
	["clock_title"] = false,
	["ap_setting"] = false,
	["enable_background"] = false,
	["rt_clothing"] = false,
	["xpvp_enabled"] = "Earned %",
	["creature_xp_bar_enabled"] = false,
	["ShiftX"] = 0,
	["soulgem_setting"] = "Empty / Full",
	["level_enabled"] = true,
	["lock_in_place"] = false,
	["horse_setting"] = "Countdown",
	["horse_trainFull"] = true,
	["timerGroup"] = true,
	["lock_horizontal"] = true,
	["gold_setting"] = true,
	["writs_setting"] = false,
	["xmute_setting"] = "Available",
	["xmute_warn"] = 25,
	["eventtickets_setting"] = false,
	["eventtickets_warn"] = 10,
	["xp_bar_enabled"] = true,
	["player_race_enabled"] = false,
	["bump_compass"] = true,
	["horse_icon"] = true,
	["rt_wood"] = false,
	["rt_jewel"] = false,
	["fps_enabled"] = true,
	["latency_enabled"] = true,
	["durability_enabled"] = true,
	["clock_type"] = "12 hour",
	["white_text"] = false,
	["spacer_style"] = "Dot",
	["hide_in_dialog"] = true,
}

_addon.Feature = {}
_addon.Feature.Toolbar = {}

_addon.LoadSavedVariables = function( self )
	local setDefault = function( parm, default ) if _addon.Settings[ parm ] == nil then _addon.Settings[ parm ] = default end end

	setDefault( "hide_in_dialog", true )
	setDefault( "align_tools", "CENTER" )
	setDefault( "lock_in_place", false )
	setDefault( "lock_horizontal", true )
	setDefault( "bump_compass", true )
	setDefault( "enable_background", false )
	setDefault( "white_text", false )
	setDefault( "scale", 100 )
	setDefault( "spacer_style", "Dot" )
	setDefault( "clock_type", "12 hour" )
	setDefault( "clock_title", false )
	setDefault( "clock_suffix", true )
	setDefault( "fps_enabled", true )
	setDefault( "fps_low", 15 )
	setDefault( "fps_mid", 22 )
	setDefault( "latency_enabled", true )
	setDefault( "latency_high", 300 )
	setDefault( "latency_mid", 150 )
	setDefault( "player_name_enabled", false )
	setDefault( "player_race_enabled", false )
	setDefault( "player_class_enabled", false )
	setDefault( "zone_enabled", true )
	setDefault( "zone_title", false )
	setDefault( "level_enabled", true )
	setDefault( "level_title", false )
	setDefault( "xp_bar_enabled", false )
	setDefault( "xpvp_enabled", "Needed %" )
	setDefault( "xpvp_title", false )
	setDefault( "xpvp_commas", true )
	setDefault( "creature_xp_bar_enabled", false )
	setDefault( "world_xp_autohide", true )
	setDefault( "bag_setting", "Used %" )
	setDefault( "bag_icon", true )
	setDefault( "bag_title", false )
	setDefault( "bag_low", 10 )
	setDefault( "bag_mid", 25 )
	setDefault( "bank_setting", "Used / Total" )
	setDefault( "bank_icon", true )
	setDefault( "bank_title", false )
	setDefault( "bank_low", 10 )
	setDefault( "bank_mid", 25 )
	setDefault( "currency_identifier", "Icon" )
	setDefault( "currency_commas", true )
	setDefault( "ap_mode", "On" )
	setDefault( "ap_location", "Character" )
	setDefault( "crowns_mode", "On" )
	setDefault( "crowngems_mode", "On" )
	setDefault( "eventtickets_mode", "On" )
	setDefault( "eventtickets_warn", 10 )
	setDefault( "gold_mode", "On" )
	setDefault( "gold_location", "Character" )
	setDefault( "soulgem_mode", "Empty / Full" )
	setDefault( "telvar_mode", "On" )
	setDefault( "telvar_location", "Character" )
	setDefault( "xmute_mode", "Available" )
	setDefault( "xmute_warn", 25 )
	setDefault( "writs_mode", "On" )
	setDefault( "writs_location", "Character" )
	setDefault( "durability_enabled", false )
	setDefault( "durability_icon", true )
	setDefault( "durability_commas", true )
	setDefault( "weaponcharge_enabled", false )
	setDefault( "weaponcharge_icon", true )
	setDefault( "horse_setting", "Countdown" )
	setDefault( "horse_trainFull", false )
	setDefault( "horse_icon", true )
	setDefault( "rt_smithing", false )
	setDefault( "rt_clothing", false )
	setDefault( "rt_wood", false )
	setDefault( "rt_jewel", false )
	setDefault( "rt_icon", true )
	setDefault( "rt_timers", _addon.G.BAR_STR_COUNTDOWN )
	setDefault( "rt_timer_type", _addon.G.BAR_STR_TIME_TO_NEXT_FREE )
	setDefault( "rt_slots", _addon.G.BAR_STR_OFF )
	setDefault( "timerGroup", true )
	setDefault( "undaunted_keys_mode", "On" )
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = _addon.DisplayName,
		displayName = _addon.DisplayName,
		author = "Calia1120, Demiknight, jaedha",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Welcome to the Wykkyd Toolbar. If there's a feature you don't see that you want, please let us know!",
		},
		[2] = self:MakeStandardOption( self.Settings, "Hide Toolbar In Dialogs", "hide_in_dialog", true, "checkbox", { default=true, } ),
		[3] = self:MakeStandardOption( self.Settings, "Tool Alignment", "align_tools", "CENTER", "dropdown", { choices={"LEFT","CENTER","RIGHT"},default="CENTER", } ),
		[4] = self:MakeStandardOption( self.Settings, "Lock Toolbar In Place", "lock_in_place", false, "checkbox", { default=false, } ),
		[5] = self:MakeStandardOption( self.Settings, "Lock Horizontal Center", "lock_horizontal", true, "checkbox", { default=true, } ),
		[6] = self:MakeStandardOption( self.Settings, "Bump Compass Down", "bump_compass", true, "checkbox", { tooltip="Only bumps the compass if locked to center AND if top of frame is at the top of screen", default=true, } ),
		[7] = self:MakeStandardOption( self.Settings, "Enable Background", "enable_background", false, "checkbox", { default=false, } ),
		[8] = self:MakeStandardOption( self.Settings, "Use Only White Text", "white_text", false, "checkbox", { default=false, } ),
		[9] = self:MakeStandardOption( self.Settings, "Toolbar Scale", "scale", 100, "slider", { min=50, max=150, step=1, default=100, } ),
		[10] = self:MakeStandardOption( self.Settings, "Spacer Style", "spacer_style", "Dot", "dropdown", { choices={"Off","Box","Dash","Dot","Horizontal Line","Map Icon","Vertical Line", },default="Dot", } ),
		[11] = { type = "divider", name = "divider1", controls = nil,},
		[12] = { type = "submenu", name = "|cCAB222".."Clock / FPS / Ping".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Time Setting", "clock_type", "12 hour", "dropdown", { choices={"Off","24 hour","12 hour"},default="12 hour", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "clock_title", false, "checkbox", { width="half",default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show AM/PM", "clock_suffix", true, "checkbox", { width="half",default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "divider 2", "divider2", nil, "divider", nil ),
				[5] = self:MakeStandardOption( self.Settings, "Show FPS", "fps_enabled", true, "checkbox", { default=true, } ),
				[6] = self:MakeStandardOption( self.Settings, "Low Threshold", "fps_low", 15, "slider", { width="half",min=5, max=60, step=1, default=15, } ),
				[7] = self:MakeStandardOption( self.Settings, "Moderate Threshold", "fps_mid", 22, "slider", { width="half",min=20, max=144, step=1, default=22, } ),
				[8] = self:MakeStandardOption( self.Settings, "divider 3", "divide3", nil, "divider", nil ),
				[9] = self:MakeStandardOption( self.Settings, "Show Ping Rate", "latency_enabled", true, "checkbox", { default=true, } ),
				[10] = self:MakeStandardOption( self.Settings, "Bad Latency", "latency_high", 300, "slider", { width="half",min=100, max=1000, step=1, default=300, } ),
				[11] = self:MakeStandardOption( self.Settings, "Poor Latency", "latency_mid", 150, "slider", { width="half",min=50, max=400, step=1, default=150, } ),
			},
		},
		[13] = { type = "submenu", name = "|cCAB222".."Character / Zone".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Name", "player_name_enabled", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Race", "player_race_enabled", false, "checkbox", { default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Class", "player_class_enabled", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "divider 4", "divider4", nil, "divider", nil ),
				[5] = self:MakeStandardOption( self.Settings, "Show Zone", "zone_enabled", true, "checkbox", { default=true, } ),
				[6] = self:MakeStandardOption( self.Settings, "Show Title", "zone_title", false, "checkbox", { width="half",default=false, } ),
			},
		},
		[14] = { type = "submenu", name = "|cCAB222".."Level / XP".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Level", "level_enabled", true, "checkbox", { default=true, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Title", "level_title", false, "checkbox", { width="half",default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "divider 5", "divider5", nil, "divider", nil ),
				[4] = self:MakeStandardOption( self.Settings, "Show XP Bar", "xp_bar_enabled", false, "checkbox", { default=false, } ),
				[5] = self:MakeStandardOption( self.Settings, "Show XP/CP Amount", "xpvp_enabled", "Needed %", "dropdown", { choices={"Off","Earned / Total","Earned","Earned % / Total","Earned %","Needed","Needed %"},default="Needed %", } ),
				[6] = self:MakeStandardOption( self.Settings, "Show Title", "xpvp_title", false, "checkbox", { width="half",default=false, } ),
				[7] = self:MakeStandardOption( self.Settings, "Use Commas", "xpvp_commas", true, "checkbox", { width="half",default=true, } ),
				[8] = self:MakeStandardOption( self.Settings, "divider 6", "divider6", nil, "divider", nil ),
				[9] = self:MakeStandardOption( self.Settings, "Show 'Creature' XP Bar", "creature_xp_bar_enabled", false, "checkbox", { default=false, } ),
				[10] = self:MakeStandardOption( self.Settings, "Autohide World 'Creature' XP Bar", "world_xp_autohide", true, "checkbox", { default=true, } ),
			},
		},
		[15] = { type = "submenu", name = "|cCAB222".."Bag Space".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Bag Space", "bag_setting", "Used %", "dropdown", { choices={"Off","Used / Total","Used Space","Used %","Free Space","Free %"},default="Used %", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "bag_icon", true, "checkbox", { width="half",default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Title", "bag_title", false, "checkbox", { width="half",default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Low Space Threshold", "bag_low", 10, "slider", { width="half",min=5, max=15, step=1, default=10, } ),
				[5] = self:MakeStandardOption( self.Settings, "Moderate Space Threshold", "bag_mid", 25, "slider", { width="half",min=10, max=35, step=1, default=25, } ),
			},
		},
		[16] = { type = "submenu", name = "|cCAB222".."Bank Space".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Bank Space", "bank_setting", "Used / Total", "dropdown", { choices={"Off","Used / Total","Used Space","Used %","Free Space","Free %"},default="Used / Total", } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "bank_icon", true, "checkbox", { width="half",default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Title", "bank_title", false, "checkbox", { width="half",default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Low Space Threshold", "bank_low", 10, "slider", { width="half",min=5, max=15, step=1, default=10, } ),
				[5] = self:MakeStandardOption( self.Settings, "Moderate Space Threshold", "bank_mid", 25, "slider", { width="half",min=10, max=35, step=1, default=25, } ),
			},
		},
		[17] = { type = "submenu", name = "|cCAB222".."Currencies".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Identifier", "currency_identifier", "Icon", "dropdown", { choices={"None","Icon","Title"},default="Icon", } ),
				[2] = self:MakeStandardOption( self.Settings, "Use Commas", "currency_commas", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Alliance Points", nil, nil, "header", nil ),
				[4] = self:MakeStandardOption( self.Settings, "Display Mode", "ap_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[5] = self:MakeStandardOption( self.Settings, "Location", "ap_location", "Character", "dropdown", { choices={"Account","Bank","Character"},default="Character", } ),
				[6] = self:MakeStandardOption( self.Settings, "Crowns", nil, nil, "header", nil ),
				[7] = self:MakeStandardOption( self.Settings, "Display Mode", "crowns_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[8] = self:MakeStandardOption( self.Settings, "Crown Gems", nil, nil, "header", nil ),
				[9] = self:MakeStandardOption( self.Settings, "Display Mode", "crowngems_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[10] = self:MakeStandardOption( self.Settings, "Event Tickets", nil, nil, "header", nil ),
				[11] = self:MakeStandardOption( self.Settings, "Display Mode", "eventtickets_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[12] = self:MakeStandardOption( self.Settings, "Warning Threshold", "eventtickets_warn", 10, "slider", { min=0, max=12, step=1, default=10, } ),
				[13] = self:MakeStandardOption( self.Settings, "Gold", nil, nil, "header", nil ),
				[14] = self:MakeStandardOption( self.Settings, "Display Mode", "gold_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[15] = self:MakeStandardOption( self.Settings, "Location", "gold_location", "Character", "dropdown", { choices={"Account","Bank","Character"},default="Character", } ),
				[16] = self:MakeStandardOption( self.Settings, "Soul Gems", nil, nil, "header", nil ),
				[17] = self:MakeStandardOption( self.Settings, "Display Mode", "soulgem_mode", "Empty / Full", "dropdown", { choices={"Off","Empty / Full","Empty","Full"},default="Empty / Full", } ),
				[18] = self:MakeStandardOption( self.Settings, "Tel Var Stones", nil, nil, "header", nil ),
				[19] = self:MakeStandardOption( self.Settings, "Display Mode", "telvar_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[20] = self:MakeStandardOption( self.Settings, "Location", "telvar_location", "Character", "dropdown", { choices={"Account","Bank","Character"},default="Character", } ),
				[21] = self:MakeStandardOption( self.Settings, "Transmute Crystals", nil, nil, "header", nil ),
				[22] = self:MakeStandardOption( self.Settings, "Display Mode", "xmute_mode", "Available", "dropdown", { choices={"Off","Available / Max","Available"},default="Available", } ),
				[23] = self:MakeStandardOption( self.Settings, "Free Spots Left Warning", "xmute_warn", 25, "slider", { min=0, max=100, step=5, default=25, } ),
				[24] = self:MakeStandardOption( self.Settings, "Writ Vouchers", nil, nil, "header", nil ),
				[25] = self:MakeStandardOption( self.Settings, "Display Mode", "writs_mode", "On", "dropdown", { choices={"On","Off"},default="On", } ),
				[26] = self:MakeStandardOption( self.Settings, "Location", "writs_location", "Character", "dropdown", { choices={"Account","Bank","Character"},default="Character", } ),
				[27] = self:MakeStandardOption( self.Settings, "Undaunted Keys", nil, nil, "header", nil ),
				[28] = self:MakeStandardOption( self.Settings, "Display Mode", "undaunted_keys_mode", "On", "dropdown", { choices = {"On", "Off"}, default = "On", } ),
			},
		},
		[18] = { type = "submenu", name = "|cCAB222".."Repair Cost / Weapon Charge".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Repair Cost", "durability_enabled", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Show Icon", "durability_icon", true, "checkbox", { width="half",default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Use Commas", "durability_commas", true, "checkbox", { width="half",default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "divider 11", "divider11", nil, "divider", nil ),
				[5] = self:MakeStandardOption( self.Settings, "Show Weapon Charge Bar(s)", "weaponcharge_enabled", false, "checkbox", { default=false, } ),
				[6] = self:MakeStandardOption( self.Settings, "Show Icon", "weaponcharge_icon", true, "checkbox", { width="half",default=true, } ),
			},
		},
		[19] = { type = "submenu", name = "|cCAB222".."Horse Training / Research Timers".."|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Show Training Timer", "horse_setting", "Countdown", "dropdown", { choices={"Off","Fancy","Descriptive","Countdown"},default="Countdown", } ),
				[2] = self:MakeStandardOption( self.Settings, "Hide Training Timer when all maxed", "horse_trainFull", false, "checkbox", {tooltip="This option will remove Horse Training from the bar once maxed out at 60/60/60.  If this option is not on then the timer will always show 60/60/60 when maxed.", default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, "Show Horse Icon", "horse_icon", true, "checkbox", { default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "divider 12", "divider12", nil, "divider", nil ),
				[5] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_SMITH, "rt_smithing", false, "checkbox", { width="half",default=false, } ),
				[6] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_CLOTH, "rt_clothing", false, "checkbox", { width="half",default=false, } ),
				[7] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_WOOD, "rt_wood", false, "checkbox", { width="half",default=false, } ),
				[8] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_JEWEL, "rt_jewel", false, "checkbox", { width="half",default=false, } ),
				[9] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_CRAFT_ICON, "rt_icon", true, "checkbox", { default=true, } ),
				[10] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SHOW_CRAFT, "rt_timers", _addon.G.BAR_STR_COUNTDOWN, "dropdown", { choices={_addon.G.BAR_STR_OFF,_addon.G.BAR_STR_FANCY_STUDY,_addon.G.BAR_STR_DESCRIPTIVE,_addon.G.BAR_STR_PERCENTAGE_LEFT,_addon.G.BAR_STR_PERCENTAGE_DONE,_addon.G.BAR_STR_ADAPTIVE,_addon.G.BAR_STR_ADAPTIVEDAYS,_addon.G.BAR_STR_COUNTDOWN},default=_addon.G.BAR_STR_COUNTDOWN, } ),
				[11] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_TIMER_TARGET, "rt_timer_type", _addon.G.BAR_STR_TIME_TO_NEXT_FREE, "dropdown", { choices={_addon.G.BAR_STR_TIME_TO_NEXT_FREE,_addon.G.BAR_STR_TIME_TO_ALL_FREE},default=_addon.G.BAR_STR_TIME_TO_NEXT_FREE, } ),
				[12] = self:MakeStandardOption( self.Settings, _addon.G.BAR_STR_SLOTS, "rt_slots", _addon.G.BAR_STR_OFF, "dropdown", { choices={_addon.G.BAR_STR_OFF,_addon.G.BAR_STR_SLOTS_TOTAL,_addon.G.BAR_STR_SLOTS_USED,_addon.G.BAR_STR_SLOTS_FREE,_addon.G.BAR_STR_SLOTS_USED_TOTAL,_addon.G.BAR_STR_SLOTS_FREE_TOTAL},default=_addon.G.BAR_STR_OFF, } ),
				[13] = self:MakeStandardOption( self.Settings, "Group all toolbar timers", "timerGroup", true, "checkbox", { tooltip="When set this option will move the Horse Training timer to group with the Research Timers.", warning="Reloads UI when changed", default=true, } ),
			},
		},
	}
	optionsTable[19].controls[13].setFunc = function( val )
		self.Settings[ "timerGroup" ] = val
		_addon:ReloadUI()
	end
	optionsTable[2].setFunc = function( val )
		self.Settings["hide_in_dialog"] = val
		_addon:ReloadUI()
	end
	optionsTable[3].setFunc = function( val ) self.Settings["align_tools"] = val
		wykkydsToolbar:SetFrameCoords()
	end
	optionsTable[4].setFunc = function( val ) self.Settings["lock_in_place"] = val
		wykkydsToolbar:SetMouseEnabled(not val)
		wykkydsToolbar:SetMovable(not val)
	end
	optionsTable[5].setFunc = function( val ) self.Settings["lock_horizontal"] = val
		wykkydsToolbar:SetFrameCoords()
	end
	optionsTable[7].setFunc = function( val ) self.Settings["enable_background"] = val
		if val then if wykkydsToolbar.bg:IsHidden() then wykkydsToolbar.bg:SetHidden(false); end
		else if not wykkydsToolbar.bg:IsHidden() then wykkydsToolbar.bg:SetHidden(true); end
		end
	end

	local xx = _addon:GetCountOf( optionsTable )
	local fixFunc = function( targ )
		if targ.type == "description" then return end
		local ff = targ.setFunc
		targ.setFunc = function( val )
			ff( val )
			_addon.Feature.Toolbar.Redraw()
		end
	end
	for yy = 7, xx, 1 do
		if optionsTable[yy].type == "submenu" then
			local zz = _addon:GetCountOf( optionsTable[yy].controls )
			for aa = 1, zz, 1 do fixFunc( optionsTable[yy].controls[aa] ) end
		else
			fixFunc( optionsTable[yy] )
		end
	end

	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.toggleBar = function()
	wykkydsToolbar:SetHidden(not wykkydsToolbar:IsHidden() )
end

_addon.Initialize = function( self )
	_addon.Feature.Toolbar.Create()
	_addon:OnUpdateCallback( "wykkydsToolbar_UpdateTic", wykkydsToolbar.UpdateAll, .5 )
	ZO_CreateStringId("SI_BINDING_NAME_WYK_TOGGLE", "Show/Hide Toolbar")
end

if wykkydsToolbarGlobal == nil then wykkydsToolbarGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsToolbarGlobal", true
)

WYK_Toolbar = _addon
