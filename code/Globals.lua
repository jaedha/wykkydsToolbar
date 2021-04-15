local _addon = WYK_Toolbar

_addon.G = {}

_addon.G.BAR_TOOL_BACKPACK = 1
_addon.G.BAR_TOOL_FPS = 2
_addon.G.BAR_TOOL_TIME = 3
_addon.G.BAR_TOOL_GOLD = 4
_addon.G.BAR_TOOL_XP = 5
_addon.G.BAR_TOOL_ZONE = 6
_addon.G.BAR_TOOL_AP = 7
_addon.G.BAR_TOOL_XPBar = 8
_addon.G.BAR_TOOL_NAME = 9
_addon.G.BAR_TOOL_RACE = 10
_addon.G.BAR_TOOL_CLASS = 11
_addon.G.BAR_TOOL_LEVEL = 12
_addon.G.BAR_TOOL_GEMS = 13
_addon.G.BAR_TOOL_HORSE = 14
_addon.G.BAR_TOOL_SpecialWorldXPBar = 15
_addon.G.BAR_TOOL_SMITH = 16
_addon.G.BAR_TOOL_WOOD  = 17
_addon.G.BAR_TOOL_CLOTH = 18
_addon.G.BAR_TOOL_JEWEL = 19
_addon.G.BAR_DURABILITY = 20
_addon.G.BAR_WEAPONCHARGE = 21
_addon.G.BAR_PINGRATE = 22 
_addon.G.BAR_TOOL_XMUTE = 23
_addon.G.BAR_TOOL_WRITS = 24
_addon.G.BAR_TOOL_EVENT_TICKETS = 25
_addon.G.BAR_TOOL_BANK = 26
_addon.G.BAR_TOOL_CROWNS = 27
_addon.G.BAR_TOOL_CROWN_GEMS = 28
_addon.G.BAR_TOOL_TELVAR = 29



_addon.TSetting = function( toolID )
	if toolID == _addon.G.BAR_TOOL_BACKPACK then return _addon:GetOrDefault( "Used %", _addon.Settings["bag_setting"] ) end
	if toolID == _addon.G.BAR_TOOL_FPS then return _addon:GetOrDefault( true, _addon.Settings["fps_enabled"] ) end
	if toolID == _addon.G.BAR_PINGRATE then return _addon:GetOrDefault( true, _addon.Settings["latency_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_TIME then return _addon:GetOrDefault( "12 hour", _addon.Settings["clock_type"] ) end
	if toolID == _addon.G.BAR_TOOL_GOLD then return _addon:GetOrDefault( true, _addon.Settings["gold_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_WRITS then return _addon:GetOrDefault( false, _addon.Settings["writs_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_XP then return _addon:GetOrDefault( "Needed %", _addon.Settings["xpvp_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_ZONE then return _addon:GetOrDefault( true, _addon.Settings["zone_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_AP then return _addon:GetOrDefault( true, _addon.Settings["ap_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_XPBar then return _addon:GetOrDefault( true, _addon.Settings["xp_bar_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_NAME then return _addon:GetOrDefault( false, _addon.Settings["player_name_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_RACE then return _addon:GetOrDefault( false, _addon.Settings["player_race_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_CLASS then return _addon:GetOrDefault( false, _addon.Settings["player_class_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_LEVEL then return _addon:GetOrDefault( true, _addon.Settings["level_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_GEMS then return _addon:GetOrDefault( "Empty / Full", _addon.Settings["soulgem_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_HORSE then return _addon:GetOrDefault( "Countdown", _addon.Settings["horse_setting"] ) end
	if toolID == _addon.G.BAR_TOOL_SpecialWorldXPBar then return _addon:GetOrDefault( false, _addon.Settings["creature_xp_bar_enabled"] ) end
	if toolID == _addon.G.BAR_DURABILITY then return _addon:GetOrDefault( false, _addon.Settings["durability_enabled"] ) end
	if toolID == _addon.G.BAR_WEAPONCHARGE then return _addon:GetOrDefault( false, _addon.Settings["weaponcharge_enabled"] ) end
	if toolID == _addon.G.BAR_TOOL_SMITH then return _addon:GetOrDefault( false, _addon.Settings["rt_smithing"] ) end
	if toolID == _addon.G.BAR_TOOL_WOOD then return _addon:GetOrDefault( false, _addon.Settings["rt_wood"] ) end
	if toolID == _addon.G.BAR_TOOL_CLOTH then return _addon:GetOrDefault( false, _addon.Settings["rt_clothing"] ) end
	if toolID == _addon.G.BAR_TOOL_JEWEL then return _addon:GetOrDefault( false, _addon.Settings["rt_jewel"] ) end	
	if toolID == _addon.G.BAR_TOOL_XMUTE then return _addon:GetOrDefault( true, _addon.Settings["xmute_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_EVENT_TICKETS then return _addon:GetOrDefault( false, _addon.Settings["eventtickets_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_BANK then return _addon:GetOrDefault( "Used / Total", _addon.Settings["bank_setting"] ) end
	if toolID == _addon.G.BAR_TOOL_CROWNS then return _addon:GetOrDefault( "On", _addon.Settings["crowns_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_CROWN_GEMS then return _addon:GetOrDefault( "On", _addon.Settings["crowngems_mode"] ) end
	if toolID == _addon.G.BAR_TOOL_TELVAR then return _addon:GetOrDefault( "On", _addon.Settings["telvar_mode"] ) end	
end

_addon.G.BAR_STR_SHOW_SMITH             = "Dewi's Smithing Research"
_addon.G.BAR_STR_SHOW_WOOD              = "Dewi's Woodwork Research"
_addon.G.BAR_STR_SHOW_CLOTH             = "Dewi's Clothier Research"
_addon.G.BAR_STR_SHOW_JEWEL				= "Dewi's Jewelry Research"
_addon.G.BAR_STR_CRAFT_ICON             = "Include Craft-type Icons"
_addon.G.BAR_STR_RESEARCH_ICONS         = "Include Research-type Icons"

_addon.G.BAR_STR_SHOW_CRAFT             = "Dewi's Research Timer Style"
_addon.G.BAR_STR_OFF                    = "Off"
_addon.G.BAR_STR_FANCY_STUDY            = "Fancy ('Study', 'Read', etc)"
_addon.G.BAR_STR_DESCRIPTIVE            = "Descriptive ('12 hours', '35 minutes', etc)"
_addon.G.BAR_STR_PERCENTAGE_LEFT        = "Percentage left ('27%')"
_addon.G.BAR_STR_PERCENTAGE_DONE        = "Percentage done ('73%')"
_addon.G.BAR_STR_ADAPTIVE               = "Adaptive ('hh:mm' or 'mm:ss')"
_addon.G.BAR_STR_ADAPTIVEDAYS           = "Adaptive with days ('dd hh:mm' or 'mm:ss')"
_addon.G.BAR_STR_COUNTDOWN              = "Countdown ('hh:mm:ss')"

_addon.G.BAR_STR_TIMER_TARGET           = "Timer Target Time"
_addon.G.BAR_STR_TIME_TO_NEXT_FREE      = "Time to next free slot"
_addon.G.BAR_STR_TIME_TO_ALL_FREE       = "Time to all slots free"

_addon.G.BAR_STR_SLOTS                  = "Dewi's Research Slots"
_addon.G.BAR_STR_SLOTS_TOTAL            = "Total Slots"
_addon.G.BAR_STR_SLOTS_USED             = "Slots Used"
_addon.G.BAR_STR_SLOTS_FREE             = "Slots Free"
_addon.G.BAR_STR_SLOTS_USED_TOTAL       = "Slots Used/Total Slots"
_addon.G.BAR_STR_SLOTS_FREE_TOTAL       = "Slots Free/Total Slots"

_addon.G.BAR_STR_STUDY_1                = "Confused..."
_addon.G.BAR_STR_STUDY_2                = "Fact finding"
_addon.G.BAR_STR_STUDY_3                = "Processing"
_addon.G.BAR_STR_STUDY_4                = "Studying"
_addon.G.BAR_STR_STUDY_5                = "Pondering"
_addon.G.BAR_STR_STUDY_6                = "Analyzing"
_addon.G.BAR_STR_STUDY_HALF             = "Getting it!"
_addon.G.BAR_STR_STUDY_7                = "Examining"
_addon.G.BAR_STR_STUDY_8                = "Inspecting"
_addon.G.BAR_STR_STUDY_9                = "Theorizing"
_addon.G.BAR_STR_STUDY_10               = "Memorizing"
_addon.G.BAR_STR_STUDY_11               = "Testing"
_addon.G.BAR_STR_STUDY_12               = "Documenting"
_addon.G.BAR_STR_STUDY_13               = "Documenting"
_addon.G.BAR_STR_STUDY_14               = "Almost done!"
_addon.G.BAR_STR_STUDY_DONE             = "Job's done!"
_addon.G.BAR_STR_HOURS                  = "Hours"
_addon.G.BAR_STR_MINUTES                = "Minutes"
_addon.G.BAR_STR_SECONDS                = "Seconds"

_addon.G.BAR_TOOLS = {}

_addon.G.SOUL_GEM_PETTY = 1
_addon.G.SOUL_GEM_MINOR = 11
_addon.G.SOUL_GEM_LESSER = 21
_addon.G.SOUL_GEM_COMMON = 31
_addon.G.SOUL_GEM_GREATER = 41
_addon.G.SOUL_GEM_GRAND = 50

_addon.G.SOUL_GEM_LOC_INVENTORY = true
_addon.G.SOUL_GEM_LOC_ANYWHERE = false
_addon.G.Compass_Bumped = 0
