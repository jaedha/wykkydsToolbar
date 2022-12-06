 --[[
	LibWykkydFactory, or LWF, is an addon registration and handling framework that imparts a standard functionality base to all registered addons including
	a series of global variables and API functions designed to simplify development of addons by standardizing repetitive tasks. It is loaded via LibStub and as such
	expects a functional copy of LibStub to be loaded prior to starting up.

	Please use wykkydsMailbox as an example addon for how to consume this Factory. Better documentation will come in the future ;)
]]--

local wm = GetWindowManager()
local lwf4 = {
	name = "LibWykkydFactory",
	_v = {
		major 	= 4,
		monthly = 4,
		daily 	= 0,
		minor 	= 0,
	},
	__internal = {
		-- populated in lwf4.__internalize()
		__internalized = false,
	},
	__extension = {
		-- populated in lwf4.__extend()
		__extended = false,
	},
	mem = {
		-- populated in lwf4 memory state
		bufferList = {},
		UniqueNamesUsed = {},
		EventRegistry = {},
		TicRegistry = {},
		_RegisteredToGlobalHandler = {},
		_NumRegisteredToGlobalHandler = {},
		_hasUnregistered = {},
		SlashCommands = {},
		Addons = {},
		AddonState = {},
		UIModeRegisteredWindows = {},
		__updateTicRegistered = false,
		soundDelay = {},
	},
	data = {
		-- populated in lwf4.__hydrate()
		__hydrated = false,
		ChatChannels = {},
		TextAlign = {},
		EquipSlot = {},
		EquipSlotBagSlot = {},
		EquipSlotDescrByBagSlot = {},
		EquipBagSlot = {},
		GameImages = {},
		GameSounds = {},
		GameSoundsByIndex = {},
		KeyMap = {},
		Emotes = {},
		EmotesSorted = {},
		GameEventTable = {},
		GameEventsByCode = {},
	},
	UI = {
		-- populated in lwf4.__struct()
		__structured = false,
	},
	LAM = {},
}
lwf4.version = string.format("%d.%d.%d.%d",lwf4._v.major,lwf4._v.monthly,lwf4._v.daily,lwf4._v.minor)
lwf4.MAJOR = string.format("%s-%d",lwf4.name,lwf4._v.major)
lwf4.MINOR = tonumber(string.format("2014%02d%02d%03d", lwf4._v.monthly, lwf4._v.daily, lwf4._v.minor))
lwf4.__index = lwf4

if LibStub then lwf4.libStub, lwf4.oldminor = LibStub:NewLibrary(lwf4.MAJOR, lwf4.MINOR) end
if LWF4_DEFAULT_CHAT_COLOR == nil then LWF4_DEFAULT_CHAT_COLOR = "|cBDBDBD" end

lwf4.__internalize = function()
	if not LWF4 then return end
	if LWF4.__internal.__internalized then return end
	LWF4.__internal.BufferPause = function( key, buffer )
		if not LWF4 then return end
		if not key then return end
		local ct, buffer = (GetFrameTimeMilliseconds()/1000), buffer or 3
		if not LWF4.mem.bufferList[key] then LWF4.mem.bufferList[key] = ct end
		if (ct - LWF4.mem.bufferList[key]) >= buffer
		then LWF4.mem.bufferList[key] = ct; return true;
		else return false; end
	end
	LWF4.__internal.comma_number = function(amount)
		if amount == nil then return nil; end
		if type(amount) == "string" then amount = tonumber( amount ) end
		if type(amount) ~= "number" then return amount; end
		if amount < 1000 then return amount; end
		return FormatIntegerWithDigitGrouping( amount, GetString( SI_DIGIT_GROUP_SEPARATOR ) )
	end
	LWF4.__internal.DumpCommandsToChat = function()
        table.foreach(_G,LWF4.__internal.Print); end
	LWF4.__internal.DumpWindowName = function(win,num)
        if win then LWF4.__internal.Print(Indent(num, win:GetName())); end end
	LWF4.__internal.DumpWindowsToChat = function(win,num)
		if not LWF4 then return end
		if not win and not num then
			LWF4.__internal.DumpWindowsToChat(GuiRoot)
			return
		end
		if not win then return end
		local nn = num or 0
		local xx = nn + 1
		LWF4.__internal.DumpWindowName(win,nn)
		local x = win:GetNumChildren()
		if x > 0 then
			for ii = 1, x do LWF4.__internal.DumpWindowsToChat(win:GetChild(ii),xx) end
		end
	end
	LWF4.__internal.EventName = function( EventToWatch )
		if not LWF4 then return end
		LWF4.__hydrate()
		for e,t in pairs(LWF4.data.GameEventTable) do
			if t.DESCR == EventToWatch or t.CODE == EventToWatch
			then return t.DESCR end
		end
		return nil
	end
	LWF4.__internal.FindFrame = function(frameName) return _G[frameName] end
	LWF4.__internal.FindGameImage = function( txt, dumpToChat )
		if not LWF4 then return end
		LWF4.__hydrate()
		local lst = {}
		for _,v in pairs(LWF4.data.GameImages) do
			if string.find(v, string.lower(LWF4.__internal.string_trim(txt))) then
				lst[LWF4.__internal.table_next(lst)] = v
				if dumpToChat then LWF4.__internal.Print( v ) end
			end
		end
		return lst
	end
	LWF4.__internal.GetDateTimeString = function()
		local ts = GetTimeStamp()
		if not ts then return nil end
		local dt = GetDateStringFromTimestamp(ts) or ""
		local tm = GetTimeString() or ""
		return dt.." "..tm
	end
	LWF4.__internal.GetOrDefault = function(default, value)
        if value == nil then return default
        else return value end
    end
	LWF4.__internal.GuildName = function(n)
        return GetGuildName(GetGuildId(n)) or "<no guild "..tostring(n)..">" end
	LWF4.__internal.Indent = function( num, msg )
		local r = ""
		if msg == nil then msg = "" end
		for xx = 0,tonumber(num) do r = r.."." end
		return r.." "..msg
	end
	LWF4.__internal.LoadEmotes = function()
		if not LWF4 then return end
		LWF4.data.Emotes = {}
		LWF4.data.EmotesSorted = {}
		local tbl = {}
		for e = 1, GetNumEmotes(), 1 do
			local em = GetEmoteSlashNameByIndex(e)
			if em ~= nil and LWF4.__internal.string_trim(em) ~= "" then tbl[em] = e end
		end
		for em,e in LWF4.__internal.PairsByKeys(tbl) do
			LWF4.data.Emotes[ em ] = e
			LWF4.data.EmotesSorted[ LWF4.__internal.table_next(LWF4.data.EmotesSorted) ] = { name = em, code = e }
		end
		return LWF4.data.Emotes
	end
	LWF4.__internal.MakeList = function( array )
		local lst = {}
		for _,l in ipairs(array) do lst[l] = true end
		return lst
	end
	LWF4.__internal.MillisecondsToHuman = function(ms, includeMs)
		if ms == nil and not includeMs then return "00:00:00" end
		if ms == nil then return "00:00:00:00" end
		local totalseconds = math.floor(ms / 1000)
		ms = ms % 1000
		local seconds = totalseconds % 60
		local minutes = math.floor(totalseconds / 60)
		local hours = math.floor(minutes / 60)
		minutes = minutes % 60
		if includeMs then return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, ms) end
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	end
	LWF4.__internal.PairsByKeys = function(t, f)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
			table.sort(a, f)
			local i = 0
			local iter = function ()
				i = i + 1
				if a[i] == nil then return nil
				else return a[i], t[a[i]]
			end
		end
		return iter
	end
	LWF4.__internal.Print = function( Text )
        CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage( LWF4_DEFAULT_CHAT_COLOR..tostring( Text ).."|r" ) end
	LWF4.__internal.RedGreenPowerMeter = function(val, maxVal, reverseMe)
		if not LWF4 then return end
		if val == nil or maxVal == nil then return 1, 1, 1; end
		local pct = LWF4.__internal.Round( val / maxVal, 2 )
		local ss, ee, bb = 255, 255, 0
		if pct == .50 then
			return 1, 1, 1
		elseif pct >= .51 then
			ee = 255
			ss = ss * (1 - ((pct - .50)*2))
			bb = ss
		elseif pct < .50 then
			ss = 255
			ee = ee * (pct*2)
			bb = ee
		end
		ss = ss / 255
		ee = ee / 255
		bb = bb / 255
		if reverseMe then return ss, ee, bb;
		else return ee, ss, bb; end
	end
	LWF4.__internal.Round = function(num, idp)
	  local mult = 10^(idp or 0)
	  return math.floor(num * mult + 0.5) / mult
	end
	LWF4.__internal.string_endswith = function( str, match, matchCase )
		local len1 = string.len( str )
		local len2 = string.len( match )
		if not matchCase then
			str = string.upper(str)
			match = string.upper(match)
		end
		return string.sub( str, len1-len2+1, len1 ) == match
	end
	LWF4.__internal.string_split = function( str, delim, max )
		if max == nil then max = -1 end
		if delim == nil then delim = " " end
		local ll = string.len(delim)
		local last, start, stop = 1
		local result = {}
		while max ~= 0 do
			start, stop = str:find(delim, last)
			if start == nil then break; end
			table.insert( result, str:sub( last, start-1 ) )
			last = stop+1
			max = max - 1
		end
		table.insert( result, str:sub( last ) )
		return result
	end
	LWF4.__internal.string_startswith = function( str, match, matchCase )
		local len1 = string.len( str )
		local len2 = string.len( match )
		if not matchCase then
			str = string.upper(str)
			match = string.upper(match)
		end
		return string.sub( str, 1, len2 ) == match
	end
	LWF4.__internal.string_trim = function( s )
        return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'; end
	LWF4.__internal.table_count = function( T )
        if T == nil then return 0; end; local c = 0;for _ in pairs(T) do c = c + 1 end; return c; end
	LWF4.__internal.table_next = function( T )
        if T == nil then return 0; end; if not LWF4 then return end; return LWF4.__internal.table_count( T )+1; end
	LWF4.__internal.table_remove = function( input, item )
		local i=1
		while i <= #input do
			if input[i] == item then table.remove(input, i)
			else i = i + 1 end
		end
	end
	LWF4.__internal.Tic = function( TicName, Callback, ThrottleInSeconds )
		if not LWF4 then return end
		if TicName == nil then return end
		if Callback == nil then
			LWF4.mem.TicRegistry[TicName] = nil
		else
			LWF4.mem.TicRegistry[TicName] = {}
			LWF4.mem.TicRegistry[TicName].Buffer = ThrottleInSeconds
			LWF4.mem.TicRegistry[TicName].Callback = Callback
		end
	end
	LWF4.__internal.ToggleSlashCommand = function( Command, Callback )
		if not LWF4 then return end
		if not Command then return end
		local COMMAND = Command
		if not string.find(COMMAND, "/") then COMMAND = "/"..COMMAND end
		local UCOMMAND, LCOMMAND = string.upper(COMMAND), string.lower(COMMAND)
		if Callback then
			SLASH_COMMANDS[COMMAND]  = Callback
			SLASH_COMMANDS[UCOMMAND] = Callback
			SLASH_COMMANDS[LCOMMAND] = Callback
			LWF4.mem.SlashCommands[COMMAND] = {}
			LWF4.mem.SlashCommands[COMMAND].Command = COMMAND
			LWF4.mem.SlashCommands[COMMAND].Callback = Callback
			LWF4.mem.SlashCommands[UCOMMAND] = {}
			LWF4.mem.SlashCommands[UCOMMAND].Command = UCOMMAND
			LWF4.mem.SlashCommands[UCOMMAND].Callback = Callback
			LWF4.mem.SlashCommands[LCOMMAND] = {}
			LWF4.mem.SlashCommands[LCOMMAND].Command = LCOMMAND
			LWF4.mem.SlashCommands[LCOMMAND].Callback = Callback
		else
			SLASH_COMMANDS[COMMAND]  = nil
			SLASH_COMMANDS[UCOMMAND] = nil
			SLASH_COMMANDS[LCOMMAND] = nil
			LWF4.mem.SlashCommands[COMMAND] = nil
			LWF4.mem.SlashCommands[UCOMMAND] = nil
			LWF4.mem.SlashCommands[LCOMMAND] = nil
		end
	end
	LWF4.__internal.ToggleUIFrames = function()
		if not LWF4 then return end
		if LWF4.__internal.table_count(LWF4.mem.UIModeRegisteredWindows) == 0 then return end
		local shouldBeOff = LWF4.UI.ShouldBeHidden()
		for nm,st in pairs(LWF4.mem.UIModeRegisteredWindows) do
			local obj = _G[nm]
			if obj and st ~= nil then
				if shouldBeOff then obj:Hide(true) end
				if not shouldBeOff then obj:Show() end
			end
		end
	end
	LWF4.__internal.__internalized = true
end
lwf4.__extend = function()
	if not LWF4 then return end
	if LWF4.__extension.__extended then return end
	LWF4.__extension.BufferPause = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.BufferPause( ... ) end
	LWF4.__extension.comma_number = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.comma_number( ... ) end
	LWF4.__extension.Descr = function( self )
        return self.DisplayName.." v"..self.Version end
	LWF4.__extension.DumpCommandsToChat = function( self )
        if not LWF4 then return end; LWF4.__internal.DumpCommandsToChat() end
	LWF4.__extension.DumpWindowName = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.DumpWindowName( ... ) end
	LWF4.__extension.DumpWindowsToChat = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.DumpWindowsToChat( ... ) end
	LWF4.__extension.EventName = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.EventName(...) end
	LWF4.__extension.FindFrame = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.FindFrame( ... ) end
	LWF4.__extension.FindGameImage = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.FindGameImage( ... ) end
	LWF4.__extension.GetDateTimeString = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.GetDateTimeString( ... ) end
	LWF4.__extension.GetOrDefault = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.GetOrDefault(...) end
	LWF4.__extension.GuildName = function( self,... )
        if not LWF4 then return end; LWF4.__internal.GuildName(...) end
	LWF4.__extension.Indent = function( self, ...
        ) if not LWF4 then return end; return LWF4.__internal.Indent( ... ) end
	LWF4.__extension.InjectAdvancedSettings = function( self, optionsTable, afterOption )
		local optionsCount, opts, key = self:GetCountOf( optionsTable ), {}, afterOption+1
		for ii = 1, optionsCount, 1 do
			if ii <= afterOption then opts[ii] = optionsTable[ii] end
			if ii > afterOption then opts[ii+1] = optionsTable[ii] end
		end
		opts[key] = { type = "submenu", name = "|cCAB222Advanced Setting Controls|r", controls = {}, }
		opts[key].controls[1] = { type = "description", text = "|cF8E6E0This feature-set is granted via the LibWykkydFactory4 library that this addon embeds. It allows you to set 1 character as your system's default settings, or set a character to use that default as their own settings, or to use a specific character's settings.|r" }
		opts[key].controls[2] = { type = "description", text = "All characters using System Default will update to new settings each time you click Make Me Default on a given character. All characters using a specific toon's settings will load those settings every time you load/reload.|r" }
		opts[key].controls[3] = { type = "description", text = "|cF8E6E0Any settings applied directly to a character that uses System Default or another character's settings are TEMPORARY and will be wiped out on your next load/reload. To clear this, click Reset All.|r" }
		opts[key].controls[4] = { type = "description", text = "|cF8E6E0Clicking this will save "..self.Player.."'s current settings over top of System Default.", width="half" }
		opts[key].controls[5] = { type="button", name="Save To Default", func=function() _G[self.__settingsVar][self.SavedVariableVersion]["__systemDefault"] = self.Settings; end, width="half" }
		opts[key].controls[6] = { type = "description", text = "This character should use System Default always.", width="half" }
		opts[key].controls[7] = {
			type="button", name="Load System Default", func=function()
				self.Settings = _G[self.__settingsVar][self.SavedVariableVersion]["__systemDefault"]
				self.Settings["use_system_default"] = true
				self:ReloadUI()
			end,
			warning="Causes the UI to Reload", width="half"
		}
		opts[key].controls[8] = {
			name="Mimic another character's settings",
			type="editbox", default=nil,
			warning="Causes the UI to Reload",
			setFunc=function(val) self.Settings["make_like_character"]=val; end,
			getFunc=function() return self.Settings["make_like_character"] end,
		}
		local resetButton, ww = 9, "full"
		if string.upper(string.sub(self.Name,1,6)) == "WYKKYD" and self.wykkydPreferred ~= nil then
			ww = "half"
			opts[key].controls[resetButton] = { type="button", name="Wykkyd's Preferences", func=function()
					self.GlobalSettings["wykkydsPreferred"] = self.Player
					self:ReloadUI()
				end,
				tooltip="Overwrites this characters settings with Wykkyd's preferred settings and reloads the UI",
				warning="Overwrites this characters settings with Wykkyd's preferred settings and reloads the UI",
				width=ww,
			}
			resetButton = resetButton + 1
		end
		opts[key].controls[resetButton] = { type="button", name="Reset All", func=function()
				self.Settings["make_like_character"] = nil
				self.Settings["use_system_default"] = false
				self:ReloadUI()
			end,
			warning="Causes the UI to Reload",
			width=ww,
		}
		local func = opts[key].controls[8].setFunc
		opts[key].controls[8].setFunc = function( val )
			if val == "" then val = nil end
			func( val )
			self.Settings["use_system_default"] = false
			self:ReloadUI()
		end
		return opts
	end
	LWF4.__extension.LoadEmotes = function( self, ... )
		if not LWF4 then return end
		LWF4.__internal.LoadEmotes()
		self.GLOBAL.emotes = LWF4.data.Emotes
		self.GLOBAL.emotesSorted = LWF4.data.EmotesSorted
		return self.GLOBAL.emotes
	end
	LWF4.__extension.MakeList = function( self, ... ) if not LWF4 then return end; return LWF4.__internal.MakeList( ... ) end
	LWF4.__extension.MakeStandardLAMOption = function( self, settingObj, label, settingKey, defaultValue, typeOf, extras )
		local t = {}
		t.name = label
		t.type = typeOf
		t.getFunc = function() return self:GetOrDefault( defaultValue, settingObj[ settingKey ] ) end
		t.setFunc = function( val ) settingObj[ settingKey ] = val end
		if extras then
			for k,v in pairs( extras ) do t[k] = v; end
		end
		return t
	end
	LWF4.__extension.MakeStandardLAMPanel = function( self, authorName, formatHexColor )
		local displayNameStr = self.DisplayName
		if formatHexColor then displayNameStr = formatHexColor..self.DisplayName.."|r" end
		return { type = "panel", name = self.DisplayName, displayName = displayNameStr, author = authorName, version = self.Version, registerForRefresh = true, registerForDefaults = true, }
	end
	LWF4.__extension.MillisecondsToHuman = function( self, ... ) if not LWF4 then return end; return LWF4.__internal.MillisecondsToHuman( ... ) end
	LWF4.__extension.PairsByKeys = function( self, ... ) if not LWF4 then return end; return LWF4.__internal.PairsByKeys( ... ) end
	LWF4.__extension.PlaySound = function( self, ix, vol, reps )
		local key = self.Name
		local onDelay = function( func, adj )
			if LWF4.mem.soundDelay[key] == nil then LWF4.mem.soundDelay[key] = 0 end
			if adj == nil then adj = 0 end
			zo_callLater( func, LWF4.mem.soundDelay[key] )
			LWF4.mem.soundDelay[key] = LWF4.mem.soundDelay[key] + 150 + adj
		end
		LWF4.mem.soundDelay[key] = 0
		if reps == nil then reps = 1 end
		if vol == nil then vol = 100 end
		local before = "0"
		if type(ix) == "table" then
			before = GetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME )
			onDelay( function() SetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, tostring(vol), 1 ) end )
			for ii = 1, reps, 1 do
				for k,v in pairs(ix) do
					if v ~= nil then
						if v.ix ~= nil then
							local adj = v.adj or 200
							local piece = 0
							if type(v.ix) == "string" then
								if LWF4.data.GameSounds[ ix ] then
									piece = LWF4.data.GameSounds[ ix ].parm
								end
							else
								if type(v.ix) == "number" then
									piece = LWF4.data.GameSounds[ LWF4.data.GameSoundsByIndex[ v.ix ] ].parm
								else
									piece = nil
								end
							end
							if piece ~= nil then
								onDelay( function() PlaySound( piece ) end, adj )
							end
						end
					end
				end
			end
			onDelay( function() SetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, before, 1 ) end )
			return
		else
			if type(ix) == "string" then
				if LWF4.data.GameSounds[ ix ] then
					piece = LWF4.data.GameSounds[ ix ].parm
				end
			else
				if type(ix) == "number" then
					ix = LWF4.data.GameSounds[ LWF4.data.GameSoundsByIndex[ ix ] ].parm
				else
					ix = nil
				end
			end
		end
		if ix == nil then return end
		before = GetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME )
		onDelay( function() SetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, tostring(vol), 1 ) end )
		for ii = 1, reps, 1 do onDelay( function() PlaySound( ix ) end, 200 ) end
		onDelay( function() SetSetting( SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, before, 1 ) end )
	end
	LWF4.__extension.PrepPlayerName = function( self ) self.Player = GetUnitName("player"):gsub("%^%a+","") end
	LWF4.__extension.PrepSettings = function( self )
		if self.__settingsVar ~= nil then
			local g = _G[self.__settingsVar]
			if not g then return end
			if g[self.SavedVariableVersion] == nil then g[self.SavedVariableVersion] = {} end
			if g[self.SavedVariableVersion]["global"] == nil then g[self.SavedVariableVersion]["global"] = {} end
			self.GlobalSettings = g[self.SavedVariableVersion]["global"]
			LWF4.__extension.PrepPlayerName( self )
			local pUser = self.Player
			local preferredPlayer = self.GlobalSettings["wykkydsPreferred"]
			if preferredPlayer == self.Player and self.wykkydPreferred ~= nil then
				g[self.SavedVariableVersion][self.Player] = self.wykkydPreferred
				self.GlobalSettings["wykkydsPreferred"] = nil
			else
				if self.__AdvancedSettingsEnabled then
					local useSystemDefault = false
					if g[self.SavedVariableVersion][pUser] ~= nil then
						if g[self.SavedVariableVersion][pUser]["use_system_default"] == true then
							useSystemDefault = true
						else
							if g[self.SavedVariableVersion][pUser]["make_like_character"] ~= nil then
								if g[self.SavedVariableVersion][g[self.SavedVariableVersion][pUser]["make_like_character"]] ~= nil then
									pUser = g[self.SavedVariableVersion][pUser]["make_like_character"]
								end
							end
						end
					end
					if useSystemDefault and g[self.SavedVariableVersion]["__systemDefault"] ~= nil then pUser = "__systemDefault" end
				end
				if g[self.SavedVariableVersion][pUser] == nil then g[self.SavedVariableVersion][pUser] = {} end
				if g[self.SavedVariableVersion][self.Player] == nil then
					if g[self.SavedVariableVersion]["__systemDefault"] ~= nil then
						g[self.SavedVariableVersion][self.Player] = g[self.SavedVariableVersion]["__systemDefault"]
					else
						g[self.SavedVariableVersion][self.Player] = {}
					end
				end
				if pUser ~= self.Player then
					local makeLike = g[self.SavedVariableVersion][self.Player]["make_like_character"]
					g[self.SavedVariableVersion][self.Player] = g[self.SavedVariableVersion][pUser]
					g[self.SavedVariableVersion][self.Player]["make_like_character"] = makeLike
				end
			end
			self.Settings = g[self.SavedVariableVersion][self.Player]
		end
	end
	LWF4.__extension.Print = function( self, ... ) if not LWF4 then return end; LWF4.__internal.Print( ... ) end
	LWF4.__extension.RedGreenPowerMeter = function( self, ... ) if not LWF4 then return end; return LWF4.__internal.RedGreenPowerMeter( ... ) end
	LWF4.__extension.ReloadUI = function( self, hideAlert )
		if hideAlert == true then ReloadUI(); return; end
		local r = _G["wykkydReloadWindow"] or wm:CreateTopLevelWindow("wykkydReloadWindow")
		r:SetAnchor( CENTER, GuiRoot, CENTER, 0, 0 )
		r.BG = _G["wykkydReloadWindowBG"] or wm:CreateControl("wykkydReloadWindowBG", r, CT_BACKDROP)
		r.BG:SetAnchor( CENTER, r, CENTER, 0, 0 )
		r.BG:SetDimensions( 420, 40 )
		r.BG:SetCenterColor( .15,0,0,1 )
		r.BG:SetEdgeColor( .35,0,0,1 )
		r.BG:SetEdgeTexture( "",8,1,1 )
		r.Label = _G["wykkydReloadWindowLabel"] or wm:CreateControl("wykkydReloadWindowLabel", r.BG, CT_LABEL)
		--r:SetDimensions( GuiRoot:GetWidth(), GuiRoot:GetHeight() )
		r.Label:SetAnchor( CENTER, r.BG, CENTER, 0, 0 )
		r.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 32, "outline"))
		r.Label:SetColor(1, .85, .25, 1)
		r.Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		r.Label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		r:SetDrawLayer( DL_OVERLAY )
		r.BG:SetDrawLayer( DL_OVERLAY )
		r.Label:SetDrawLayer( DL_OVERLAY )
		zo_callLater(function() r.Label:SetText( "Reloading User Interface" ) end, 0)
		zo_callLater(function() r.Label:SetText( ".Reloading User Interface." ) end, 400)
		zo_callLater(function() r.Label:SetText( "..Reloading User Interface.." ) end, 800)
		zo_callLater(function() r.Label:SetText( "...Reloading User Interface..." ) end, 1200)
		zo_callLater(function() ReloadUI() end, 1600)
	end
	LWF4.__extension.Round = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.Round( ... ) end
	LWF4.__extension.string_endswith = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.string_endswith( ... ) end
	LWF4.__extension.string_split = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.string_split( ... ) end
	LWF4.__extension.string_startswith = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.string_startswith( ... ) end
	LWF4.__extension.string_trim = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.string_trim( ... ) end
	LWF4.__extension.table_count = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.table_count( ... ) end
	LWF4.__extension.table_next = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.table_next( ... ) end
	LWF4.__extension.table_remove = function( self, ... )
        if not LWF4 then return end; LWF4.__internal.table_remove( ... ) end
	LWF4.__extension.Tic = function( self, ... )
        if not LWF4 then return end; return LWF4.__internal.Tic(...) end
	LWF4.__extension.ToggleEvent = function( self, EventToWatch, Callback, ParamsAsTable )
		if not LWF4 then return end
		LWF4.__hydrate()
		if EventToWatch == nil then return end
		local event = LWF4.__internal.EventName( EventToWatch )
		if event == nil then return end
		local AddonID = self.ID
		if LWF4.mem.EventRegistry[event] == nil then LWF4.mem.EventRegistry[event] = {} end
		if Callback == nil then
			if LWF4.mem.EventRegistry[event][AddonID] ~= nil then
				LWF4.mem.EventRegistry[event][AddonID].Unregister = true
			end
		else
			LWF4.mem.EventRegistry[event][AddonID] = {
				Code = LWF4.data.GameEventTable[event].CODE,
				Handler = Callback,
				Addon = AddonID,
				TableParms = ParamsAsTable,
			}
		end
	end
	LWF4.__extension.ToggleSlashCommand = function( self, ... )
        if not LWF4 then return end; LWF4.__internal.ToggleSlashCommand(...) end
	LWF4.__extension.ToggleUIFrames = function( self )
        if not LWF4 then return end; LWF4.__internal.ToggleUIFrames() end
	LWF4.__extension.UniqueName = function( self, NAME )
		if not LWF4 then return end
		local addon
		if self then
			addon = self.ID
		else
			addon = LWF4.name.."_MC"
		end
		if not NAME then NAME = "lWAF_Ctrl" end
		if LWF4.mem.UniqueNamesUsed[NAME] == nil and _G[NAME] == nil then
			LWF4.mem.UniqueNamesUsed[NAME] = NAME
			return NAME
		end
		if LWF4.mem.UniqueNamesUsed[NAME] == nil and _G[NAME] == nil then
			LWF4.mem.UniqueNamesUsed[NAME] = NAME
			return NAME
		end
		for c = 1, 6000, 1 do
			if LWF4.mem.UniqueNamesUsed[NAME.."_"..c] == nil and _G[NAME.."_"..c] == nil then
				LWF4.mem.UniqueNamesUsed[NAME.."_"..c] = NAME.."_"..c
				return NAME.."_"..c
			end
		end
	end
	LWF4.__extension.__extended = true
end
lwf4.__struct = function()
	if not LWF4 then return end
	if LWF4.UI.__structured then return end

	local closeButtonUp = "/esoui/art/buttons/clearslot_up.dds"
	local closeButtonDown = "/esoui/art/buttons/clearslot_down.dds"
	local unlockedButtonUp = "/esoui/art/quest/quest_untrack_up.dds"
	local unlockedButtonDown = "/esoui/art/quest/quest_untrack_down.dds"
	local lockedButtonUp = "/esoui/art/quest/quest_track_up.dds"
	local lockedButtonDown = "/esoui/art/quest/quest_track_down.dds"
	local verticalScrollTexture = "/esoui/art/miscellaneous/scrollbox_elevator.dds"

	local Chain = function( object )
		local T = {}
		setmetatable( T , { __index = function( self , func )
			if func == "__END" then	return object end
			return function( self , ... )
				assert( object[func] , func .. " missing in object" )
				object[func]( object , ... )
				return self
			end
		end })
		return T
	end

	LWF4.UI.__Chain = function( object ) return Chain( object ) end

	LWF4.UI.NewTopLevel = function(str) return wm:CreateTopLevelWindow(LWF4.__extension.UniqueName( nil, str)) end
	LWF4.UI.__NewTopLevel = function(str) return Chain( LWF4.UI.NewTopLevel(str) ) end

	local wmCreate = function( str, pappy, kind ) return wm:CreateControl(LWF4.__extension.UniqueName( nil, str), pappy or GuiRoot, kind) end

	LWF4.UI.NewBackdrop = function(str, pappy) return wmCreate(str, pappy, CT_BACKDROP) end
	LWF4.UI.__NewBackdrop = function(str, pappy) return Chain( LWF4.UI.NewBackdrop(str, pappy) ) end

	LWF4.UI.NewImage = function(str, pappy) return wmCreate(str, pappy, CT_TEXTURE) end
	LWF4.UI.__NewImage = function(str, pappy) return Chain( LWF4.UI.NewImage(str, pappy) ) end

	LWF4.UI.NewTexture = function(str, pappy) return wmCreate(str, pappy, CT_TEXTURE) end
	LWF4.UI.__NewTexture = function(str, pappy) return Chain( LWF4.UI.NewTexture(str, pappy) ) end

	LWF4.UI.NewLabel = function(str, pappy) return wmCreate(str, pappy, CT_LABEL) end
	LWF4.UI.__NewLabel = function(str, pappy) return Chain( LWF4.UI.NewLabel(str, pappy) ) end

	LWF4.UI.NewButton = function(str, pappy) return wmCreate(str, pappy, CT_BUTTON) end
	LWF4.UI.__NewButton = function(str, pappy) return Chain( LWF4.UI.NewButton(str, pappy) ) end

	LWF4.UI.NewSlider = function(str, pappy) return wmCreate(str, pappy, CT_SLIDER) end
	LWF4.UI.__NewSlider = function(str, pappy) return Chain( LWF4.UI.NewSlider(str, pappy) ) end

	LWF4.UI.NewEditBox = function(str, pappy) return wmCreate(str, pappy, CT_EDITBOX) end
	LWF4.UI.__NewEditBox = function(str, pappy) return Chain( LWF4.UI.NewEditBox(str, pappy) ) end

	LWF4.UI.NewLine = function(str, pappy) return wmCreate(str, pappy, CT_LINE) end
	LWF4.UI.__NewLine = function(str, pappy) return Chain( LWF4.UI.NewLine(str, pappy) ) end

	LWF4.UI.ShouldBeHidden = function()
		if not ZO_MainMenuCategoryBar:IsHidden() then return true end
		if not ZO_OptionsWindow:IsHidden() then return true end
		if not ZO_SharedTreeUnderlay:IsHidden() then return true end
		if not ZO_ChatterOption1:IsHidden() then return true end
        --if not STORE_WINDOW["container"]:IsHidden() then return true end
		--if not BANKING["container"]:IsHidden() then return true end
        if not DEATH["control"]:IsHidden() then return true end
		--if not STABLE["control"]:IsHidden() then return true end
		if not SMITHING["control"]:IsHidden() then return true end
		if not LOCK_PICK["control"]:IsHidden() then return true end
		if not KEYBIND_STRIP["control"]:IsHidden() then return true end
		return false
	end

	LWF4.UI.CalculateRelativeAnchor = function( frame )
		local left, top		= frame:GetLeft(), frame:GetTop()
		local right, bottom	= frame:GetRight(), frame:GetBottom()
		local rootW, rootH	= GuiRoot:GetWidth(), GuiRoot:GetHeight()
		local point			= 0
		local x, y

		if (left < (rootW - right) and left < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = left, 2 -- 'LEFT'
		elseif ((rootW - right) < math.abs((left + right) / 2 - rootW / 2)) then
			x, point = right - rootW, 8 -- 'RIGHT'
		else
			x, point = (left + right) / 2 - rootW / 2, 0
		end

		if (bottom < (rootH - top) and bottom < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = top, point + 1 -- 'TOP|TOPLEFT|TOPRIGHT'
		elseif ((rootH - top) < math.abs((bottom + top) / 2 - rootH / 2)) then
			y, point = bottom - rootH, point + 4 -- 'BOTTOM|BOTTOMLEFT|BOTTOMRIGHT'
		else
			y = (bottom + top) / 2 - rootH / 2
		end

		point = (point == 0) and 128 or point -- 'CENTER'

		return point, x, y
	end

	LWF4.UI.StandardBackdrop = {}
	function LWF4.UI.StandardBackdrop:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		obj.Backdrop = LWF4.UI.__NewBackdrop(uniqueName.."_Backdrop", parent)
			:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
			:SetDimensions( w , h )
			:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
			:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
			:SetEdgeTexture(edgeTexture[1], edgeTexture[2], edgeTexture[3], edgeTexture[4])
			:SetAlpha(alpha)
			:SetHidden(false)
		.__END
		return obj
	end

	LWF4.UI.StandardLabel = {}
	function LWF4.UI.StandardLabel:Create(parent, uniqueName, anchor, w, h, alpha, text, fontColor, cascade)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		obj.Label = LWF4.UI.__NewLabel(uniqueName.."_Label", parent)
			:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
			:SetDimensions( w , h )
			:SetFont("ZoFontGame")
			:SetColor(fontColor[1], fontColor[2], fontColor[3], fontColor[4])
			:SetAlpha(alpha)
			:SetHidden(false)
			:SetText(text)
		.__END
		return obj
	end

	LWF4.UI.StandardButton = {}
	function LWF4.UI.StandardButton:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, fontColor, cascade, textX, textY)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		local tX = textX or 0
		local tY = textY or ((h-6)*-1)
		obj = LWF4.UI.StandardBackdrop:Create(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, obj)
		obj.Button = LWF4.UI.__NewButton(uniqueName, obj.Backdrop)
			:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
			:SetDimensions( w-2 , h-2 )
			:EnableMouseButton(1,true)
			:SetEnabled(true)
			:SetHidden(false)
		.__END
		obj = LWF4.UI.StandardLabel:Create(obj.Button, uniqueName.."_Label", {CENTER, obj.Button, CENTER, tX, tY}, w-4, h-4, alpha, text, fontColor, obj)
		return obj
	end

	LWF4.UI.StandardButton2 = {}
	function LWF4.UI.StandardButton2:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, cascade)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		local tX = textX or 0
		local tY = textY or ((h-6)*-1)
		obj = LWF4.UI.StandardBackdrop:Create(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
		obj.Button = LWF4.UI.__NewButton(uniqueName, obj.Backdrop)
			:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
			:SetDimensions( w-2 , h-2 )
			:EnableMouseButton(1,true)
			:SetEnabled(true)
			:SetHidden(false)
			:SetText(text)
		.__END
		return obj
	end

	LWF4.UI.StandardImageButton = {}
	function LWF4.UI.StandardImageButton:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, imagePath, cascade)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		local tX = textX or 0
		local tY = textY or ((h-6)*-1)
		obj = LWF4.UI.StandardBackdrop:Create(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
		obj.Button = LWF4.UI.__NewButton(uniqueName, obj.Backdrop)
			:SetAnchor(CENTER, obj.Backdrop, CENTER, 0, 0)
			:SetDimensions( w-2 , h-2 )
			:EnableMouseButton(1,true)
			:SetEnabled(true)
			:SetHidden(false)
		.__END
		obj.Image = LWF4.UI.__NewImage(uniqueName.."_image", obj.Button)
			:SetAnchor(CENTER, obj.Button, CENTER, 0, 0)
			:SetDimensions(w-4, h-4)
			:SetAlpha(alpha)
			:SetTexture(imagePath)
		.__END
		return obj
	end

	LWF4.UI.StandardFrame = {}
	function LWF4.UI.StandardFrame:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, cascade)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		obj.Frame = LWF4.UI.__NewTopLevel( uniqueName )
			:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
			:SetDimensions( w, h )
			:SetHidden( false )
			:SetClampedToScreen( true )
		.__END
		obj.Backdrop = LWF4.UI.__NewBackdrop( uniqueName.."_Backdrop", obj.Frame )
			:SetAnchor(CENTER, obj.Frame, CENTER, 0, 0)
			:SetDimensions( w , h )
			:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
			:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
			:SetEdgeTexture(edgeTexture[1], edgeTexture[2], edgeTexture[3], edgeTexture[4])
			:SetAlpha(alpha)
			:SetHidden(false)
		.__END
		return obj
	end

	LWF4.UI.StandardPopup = {}
	function LWF4.UI.StandardPopup:Create( name, title, anchor, width, textLinks, closeCallback, ignoreMouseOut )
		LWF4.__hydrate()
		local obj = _G[name]
		if obj == nil then
			obj = LWF4.UI.__NewTopLevel(name)
				:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
				:SetHidden(false)
				:SetMovable(false)
				:SetMouseEnabled(true)
				:SetDimensions( width, 40 )
				:SetClampedToScreen( true )
			.__END
			obj = LWF4.UI.StandardBackdrop:Create(
				obj,
				name,
				{CENTER,obj,CENTER,0,0},
				obj:GetWidth(),
				obj:GetHeight(),
				{0.1,0.1,0.1,1},
				{0,0,0,1},
				{"", 8, 1, 1},
				1,
				obj
			)
			if title then
				obj.Title = LWF4.UI.StandardTextBlock:Create(
					obj.Backdrop,
					name.."_Title",
					{ TOPLEFT, obj.Backdrop, TOPLEFT, 1, 1 },
					width,
					16,
					{0,0,0,1},
					{0.2,0.2,0.7,1},
					{"", 8, 1, 1},
					1,
					title,
					{1,1,1,1},
					nil,
					0,
					-4
				)
				obj.Title.Backdrop:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, -1, 1 )
				obj.Title.Label:SetWidth(obj.Title.Backdrop:GetWidth()*1.7)
				obj.Title.Label:SetHorizontalAlignment(LWF4.data.TextAlign["h"]["center"])
				obj.Title.Label:SetVerticalAlignment(LWF4.data.TextAlign["v"]["center"])
				obj.Title.Label:SetScale(.85)
			end
			obj.MousedOver = false
			obj.ignoreMouseOut = ignoreMouseOut
			function obj:IsMousedOver() if obj.ignoreMouseOut then return false else return self.MousedOver end end
			function obj:MouseIn()
				obj.MousedOver = true
			end
			function obj:MouseOut()
				obj.MousedOver = false
				obj:SetHidden( true )
				LWF4.__internal.Tic( nil, name.."_hoverWatch" )
				if closeCallback ~= nil then closeCallback() end
			end
			function obj:CloseMe()
				obj:SetHidden( true )
				LWF4.__internal.Tic( nil, name.."_hoverWatch" )
			end
			function obj:ShowMe()
				obj:SetHidden( false )
				obj.MousedOver = false
				LWF4.__internal.Tic( nil, name.."_hoverWatch", function()
					if ( obj:IsMousedOver() and wm:IsMouseOverWorld() )
					or IsUnitInCombat("player")
					or IsPlayerMoving() then
						obj:MouseOut()
					end
				end )
			end
			obj:ShowMe()
			obj:SetHandler( "OnMouseEnter", function(self) obj:MouseIn() end )
			local startY, modY = 0, 0
			local widest, count = 0, 0
			if title == nil then modY = 6 end
			obj.Clickies = {}
			if textLinks ~= nil then
				if LWF4.__internal.table_count(textLinks) > 0 then
					for i,tbl in LWF4.__internal.PairsByKeys(textLinks) do
						startY = 2 + modY + (count * 20)
						count = count + 1
						local btn = LWF4.UI.StandardButton:Create(
							obj, name.."_link",
							{TOPLEFT, obj.Backdrop, TOPLEFT, 4, startY },
							width or 72, 18,
							{0,0,0,0},
							{0.2,0.2,0.7,0},
							{"", 8, 1, 0},
							1, tbl.name,
							{1,1,1,1},
							nil, nil, -4
						)
						local ww = btn.Label:GetWidth() + 2
						if ww > widest then widest = ww end
						btn.Button:SetWidth( ww )
						btn.Button:EnableMouseButton(2,true)
						btn.Button:SetHandler("OnClicked", function(self,button) tbl.onClick(self,button,tbl.params); obj:MouseOut(); end )
						btn.Button:SetHandler("OnMouseEnter", function() btn.Label:SetColor(.5,.6,1,1) end)
						btn.Button:SetHandler("OnMouseExit", function() btn.Label:SetColor(1,1,1,1) end)
						obj.Clickies[i] = btn
					end
				end
			end
			if title then count = count + 1 end
			local offset = 6
			if title then offset = 20 end
			if widest == 0 then widest = nil end
			obj.Backdrop:ClearAnchors()
			obj:SetDimensions( widest or width, (count*22)+offset )
			obj.Backdrop:SetAnchor(TOPLEFT, obj, TOPLEFT, 0, 0)
			obj.Backdrop:SetAnchor(BOTTOMRIGHT, obj, BOTTOMRIGHT, 0, 0)
			obj:SetHidden( false )
			return obj
		end
		obj.MousedOver = false
		obj:SetHidden( false )
		obj:ClearAnchors()
		obj:SetDrawLayer(2)
		obj:SetAnchor( anchor[1], anchor[2], anchor[3], anchor[4], anchor[5] )
		obj.Backdrop:ClearAnchors()
		obj.Backdrop:SetAnchor(TOPLEFT, obj, TOPLEFT, 0, 0)
		obj.Backdrop:SetAnchor(BOTTOMRIGHT, obj, BOTTOMRIGHT, 0, 0)
		if textLinks ~= nil then
			if LWF4.__internal.table_count(textLinks) > 0 then
				for i = 1, LWF4.__internal.table_count(textLinks), 1 do
					obj.Clickies[i].Button:SetHandler("OnClicked", function(self,button)
						textLinks[i].onClick(self,button,textLinks[i].params);
						obj:MouseOut();
					end )
				end
			end
		end
		obj:ShowMe()
		return obj
	end

	LWF4.UI.StandardTextBlock = {}
	function LWF4.UI.StandardTextBlock:Create(parent, uniqueName, anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, text, fontColor, cascade, textX, textY)
		if parent == nil then return end
		LWF4.__hydrate()
		local obj = cascade or {}
		local tX = textX or 0
		local tY = textY or ((h-6)*-1)
		obj = LWF4.UI.StandardBackdrop:Create(parent, uniqueName.."_Backdrop", anchor, w, h, centerColor, edgeColor, edgeTexture, alpha, obj)
		obj = LWF4.UI.StandardLabel:Create(obj.Backdrop, uniqueName.."_Label", {CENTER, obj.Backdrop, CENTER, tX, tY}, w-2, h-2, alpha, text, fontColor, obj)
		return obj
	end

	LWF4.UI.StandardWindow = {}
	function LWF4.UI.StandardWindow:Create(baseName, title, useMover, useCloser, Settings, width, height, overAlpha)
		LWF4.__hydrate()
		local obj = LWF4.__internal.FindFrame(baseName)
		if obj ~= nil then return end

		local moverText = lockedButtonUp
		if Settings.Moveable then moverText = unlockedButtonUp end

		local minW = 40 + 2
		local minH = 50

		if useMover then minW = minW + 15 end
		if useCloser then minW = minW + 15 end

		local w = width or minW
		local h = height or minH

		if w < minW then w = minW end
		if h < minH then h = minH end

		local titleWminus = 2
		if useMover then titleWminus = titleWminus + 15 end
		if useCloser then titleWminus = titleWminus + 15 end

		local a = overAlpha or .85

		obj = LWF4.UI.__NewTopLevel(baseName)
			:SetAnchor(CENTER, GuiRoot, CENTER, Settings.ShiftX, Settings.ShiftY)
			:SetDimensions(w,h)
			:SetHidden(Settings.Hidden)
			:SetMovable(Settings.Moveable)
			:SetMouseEnabled(true)
			:SetClampedToScreen( true )
		.__END

		obj.OutAlpha = .5
		obj.InAlpha = overAlpha or .85

		obj = LWF4.UI.StandardBackdrop:Create(
			obj,
			baseName,
			{CENTER,obj,CENTER,0,0},
			obj:GetWidth(),
			obj:GetHeight(),
			{0.1,0.1,0.1,1},
			{0,0,0,1},
			{"", 8, 1, 1},
			obj.OutAlpha,
			obj
		)

		obj.Title = LWF4.UI.StandardTextBlock:Create(
			obj.Backdrop,
			baseName.."_Title",
			{TOPLEFT,obj.Backdrop,TOPLEFT,1,1},
			(obj:GetWidth()-titleWminus),
			16,
			{0,0,0,1},
			{0.2,0.2,0.7,1},
			{"", 8, 1, 1},
			1,
			title,
			{1,1,1,1},
			nil,
			0,
			0
		)
		obj.Title.Label:SetWidth(obj.Title.Backdrop:GetWidth()*1.7)
		obj.Title.Label:SetAnchor(LEFT, obj.Title.Backdrop, LEFT, 3, -2)
		obj.Title.Label:SetScale(.65)

		obj.MousedOver = false
		function obj.IsMousedOver(self) return self.MousedOver end

		function obj.MouseIn()
			obj.MousedOver = true
			obj.Backdrop:SetAlpha(obj.InAlpha)
		end
		function obj.MouseOut()
			obj.MousedOver = false
			obj.Backdrop:SetAlpha(obj.OutAlpha)
		end

		if useCloser then
			obj.CloseButton = LWF4.UI.__NewImage(baseName.."_CloseButton", obj.Backdrop)
				:SetDimensions(16, 16)
				:SetTexture( closeButtonUp )
				:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, -1, 1 )
				:SetMouseEnabled( true )
				:SetHandler( "OnMouseDown", function(self) self:SetTexture( closeButtonDown ) end )
				:SetHandler( "OnMouseUp", function(self) obj:Hide(); self:SetTexture( closeButtonUp ) end )
			.__END
		end

		if useMover then
			local moveShiftX = -1
			if useCloser then moveShiftX = -18 end

			function obj.ClickMove(self, forceMoveable)
				if Settings.Moveable and not forceMoveable then self:Lock()
				else self:Move() end
			end
			function obj.Move(self)
				Settings.Moveable = true
				self.MoveButton:SetTexture( unlockedButtonUp )
				self:SetMovable(Settings.Moveable)
			end
			function obj.Lock(self)
				Settings.Moveable = false
				self.MoveButton:SetTexture( lockedButtonUp )
				self:SetMovable(Settings.Moveable)
			end

			obj.MoveButton = LWF4.UI.__NewImage(baseName.."_MoveButton", obj.Backdrop)
				:SetDimensions(16, 16)
				:SetTexture( moverText )
				:SetAnchor( TOPRIGHT, obj.Backdrop, TOPRIGHT, moveShiftX, 1 )
				:SetMouseEnabled( true )
				:SetHandler( "OnMouseDown", function(self)
					if Settings.Moveable then self:SetTexture( unlockedButtonDown )
					else self:SetTexture( lockedButtonDown ) end
				end )
				:SetHandler( "OnMouseUp", function(self) obj:ClickMove() end )
			.__END
		else
			function obj.Move(self)
				Settings.Moveable = true
				self:SetMovable(Settings.Moveable)
			end
			function obj.Lock(self)
				Settings.Moveable = false
				self:SetMovable(Settings.Moveable)
			end
		end

		if not Settings.Hidden then LWF4.mem.UIModeRegisteredWindows[obj:GetName()] = obj:GetName() end

		function obj.SetOutAlpha(self, a) self.OutAlpha = a end
		function obj.SetInAlpha(self, a) self.InAlpha = a end

		function obj.Show(self)
			if LWF4.UI.ShouldBeHidden() then return end
			LWF4.mem.UIModeRegisteredWindows[self:GetName()] = self:GetName()
			Settings.Hidden = false
			self:SetHidden(Settings.Hidden)
		end
		function obj.Hide(self, temporary)
			if temporary == nil then temporary = false end
			if temporary then
				LWF4.mem.UIModeRegisteredWindows[self:GetName()] = self:GetName()
			else
				LWF4.mem.UIModeRegisteredWindows[self:GetName()] = nil
			end
			Settings.Hidden = true
			self:SetHidden(Settings.Hidden)
		end
		function obj.Toggle(self)
			if self:IsHidden()
			then self:Show()
			else self:Hide(false) end
		end
		function obj.SetFrameCoords(self)
			local addOnX, addOnY = self:GetCenter()
			local guiRootX, guiRootY = GuiRoot:GetCenter()
			local x = addOnX - guiRootX
			local y = addOnY - guiRootY
			Settings.ShiftX = x
			Settings.ShiftY = y
		end
		obj.CanMove = Settings.Moveable
		if useMover then
			function obj.SetMoveState(self, bool)
				self.CanMove = bool
				Settings.Moveable = bool
				self:SetMovable(bool)
				self:ClickMove(bool)
			end
		else
			function obj.SetMoveState(self, bool)
				self.CanMove = bool
				Settings.Moveable = bool
				self:SetMovable(bool)
			end
		end

		obj:SetHandler("OnMoveStop", function(self) obj:SetFrameCoords() end)
		obj:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
		obj:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
		if useMover then
			obj.MoveButton:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
			obj.MoveButton:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
		end
		if useCloser then
			obj.CloseButton:SetHandler("OnMouseEnter", function(self) obj:MouseIn() end)
			obj.CloseButton:SetHandler("OnMouseExit", function(self) obj:MouseOut() end)
		end

		return obj
	end

	LWF4.UI.SelectableItem = function( itm )
		LWF4.__hydrate()
		local key = "LWF_ScrollingDDL_PopUp_Item"..itm
		if _G[key] then return _G[key] end
		local o = LWF4.UI.__NewBackdrop( key, LWF_ScrollingDDL_PopUp )
			:SetDimensions( 111, 26 )
			:SetCenterColor( .15, .15, .15, 1 )
			:SetEdgeColor( 0, 0, 0, 0 )
		.__END
		o.Label = LWF4.UI.__NewLabel( key.."Label", LWF_ScrollingDDL_PopUp )
			:SetDimensions( 100, 22 )
			:SetAnchor( LEFT, o, LEFT, 3, 0 )
			:SetFont( string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 18, "soft-shadow-thick") )
			:SetHorizontalAlignment( LWF4.data.TextAlign["h"]["left"] )
			:SetVerticalAlignment( LWF4.data.TextAlign["v"]["center"] )
			:SetMouseEnabled( true )
			:SetHandler( "OnMouseEnter", function( self, button )
				_G[key]:SetCenterColor( .15, .35, .65, 1 )
			end )
			:SetHandler( "OnMouseExit", function( self, button )
				_G[key]:SetCenterColor( .15, .15, .15, 1 )
			end )
			:SetHandler( "OnMouseWheel", function( self, button )
				if button > 0 then LWF_ScrollingDDL_PopUp.ScrollUp()
				else LWF_ScrollingDDL_PopUp.ScrollDown() end
			end )
			:SetHandler( "OnMouseDown", function( self )
				_G[key]:SetCenterColor( 0, 0, 0, .85 )
				LWF_ScrollingDDL_PopUp.ClickItem( self )
			end )
		.__END
		return o
	end

	LWF4.UI.ScrollingDDL = function()
		LWF4.__hydrate()
		if LWF_ScrollingDDL_PopUp then return LWF_ScrollingDDL_PopUp end
		local imgPath = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
		local o1 = LWF4.UI.__NewTopLevel( "LWF_ScrollingDDL_PopUp_HideAway" )
			:SetHidden( true )
		.__END
		local o = LWF4.UI.__NewTopLevel( "LWF_ScrollingDDL_PopUp" )
			:SetDimensions( 111, 110 )
			:SetHidden( true )
		.__END
		LWF_ScrollingDDL_PopUp.data = {}
		LWF_ScrollingDDL_PopUp.callBackFunc = function() return end
		LWF_ScrollingDDL_PopUp.Item1 = LWF4.UI.SelectableItem( 1 )
		LWF_ScrollingDDL_PopUp.Item2 = LWF4.UI.SelectableItem( 2 )
		LWF_ScrollingDDL_PopUp.Item3 = LWF4.UI.SelectableItem( 3 )
		LWF_ScrollingDDL_PopUp.Item4 = LWF4.UI.SelectableItem( 4 )
		LWF_ScrollingDDL_PopUp.Item5 = LWF4.UI.SelectableItem( 5 )
		LWF_ScrollingDDL_PopUp.Item1:SetAnchor( TOPLEFT )
		LWF_ScrollingDDL_PopUp.Item2:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item1, BOTTOMLEFT, 0, 0 )
		LWF_ScrollingDDL_PopUp.Item3:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item2, BOTTOMLEFT, 0, 0 )
		LWF_ScrollingDDL_PopUp.Item4:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item3, BOTTOMLEFT, 0, 0 )
		LWF_ScrollingDDL_PopUp.Item5:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item4, BOTTOMLEFT, 0, 0 )
		LWF_ScrollingDDL_PopUp.SetWidthAll = function( width )
			LWF_ScrollingDDL_PopUp:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item1:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item1.Label:SetWidth( width-11 )
			LWF_ScrollingDDL_PopUp.Item2:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item2.Label:SetWidth( width-11 )
			LWF_ScrollingDDL_PopUp.Item3:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item3.Label:SetWidth( width-11 )
			LWF_ScrollingDDL_PopUp.Item4:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item4.Label:SetWidth( width-11 )
			LWF_ScrollingDDL_PopUp.Item5:SetWidth( width )
			LWF_ScrollingDDL_PopUp.Item5.Label:SetWidth( width-11 )
		end
		LWF_ScrollingDDL_PopUp.SetCallBack = function( func )
			LWF_ScrollingDDL_PopUp.callBackFunc = func
		end
		LWF_ScrollingDDL_PopUp.slider = LWF4.UI.__NewSlider( "LWF_ScrollingDDL_PopUp_Slider", LWF_ScrollingDDL_PopUp )
			:SetAnchor( TOPLEFT, LWF_ScrollingDDL_PopUp.Item1, TOPRIGHT, -9, 6 )
			:SetThumbTexture( imgPath, imgPath, imgPath, 8, 22, 0, 0, 1, 1 )
			:SetValueStep( 1 )
			:SetDimensions( 8, 110 )
			:SetMouseEnabled( true )
			:SetHandler( "OnMouseWheel", function( self, button )
				if button > 0 then LWF_ScrollingDDL_PopUp.ScrollUp()
				else LWF_ScrollingDDL_PopUp.ScrollDown() end
			end )
			:SetHandler("OnValueChanged", function( self, value, eventReason )
				LWF_ScrollingDDL_PopUp.SetScroll( value )
			end )
		.__END
		LWF_ScrollingDDL_PopUp.ClickItem = function( itm )
			if itm then
				LWF_ScrollingDDL_PopUp:SetParent( LWF_ScrollingDDL_PopUp_HideAway )
				LWF_ScrollingDDL_PopUp:SetHidden( true )
				if itm:GetText() ~= nil and itm:GetText() ~= "" then
					LWF_ScrollingDDL_PopUp.callBackFunc( itm:GetText() )
				end
			end
		end
		LWF_ScrollingDDL_PopUp.SetListData = function( data )
			LWF_ScrollingDDL_PopUp.data = data
			LWF_ScrollingDDL_PopUp.slider:SetMinMax( 1, LWF4.__internal.table_count(data)-4 )
		end
		LWF_ScrollingDDL_PopUp.scrollPosition = 1
		LWF_ScrollingDDL_PopUp.SetScroll = function( pos )
			local maxScroll = (LWF4.__internal.table_count(LWF_ScrollingDDL_PopUp.data) - 4)
			LWF_ScrollingDDL_PopUp.scrollPosition = pos
			if LWF_ScrollingDDL_PopUp.scrollPosition <= 1 then LWF_ScrollingDDL_PopUp.scrollPosition = 1 end
			if LWF_ScrollingDDL_PopUp.scrollPosition > maxScroll then LWF_ScrollingDDL_PopUp.scrollPosition = maxScroll end
			LWF_ScrollingDDL_PopUp.slider:SetValue( LWF_ScrollingDDL_PopUp.scrollPosition )
			LWF_ScrollingDDL_PopUp.Item1.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition] ) )
			LWF_ScrollingDDL_PopUp.Item2.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+1] ) )
			LWF_ScrollingDDL_PopUp.Item3.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+2] ) )
			LWF_ScrollingDDL_PopUp.Item4.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+3] ) )
			LWF_ScrollingDDL_PopUp.Item5.Label:SetText( tostring( LWF_ScrollingDDL_PopUp.data[LWF_ScrollingDDL_PopUp.scrollPosition+4] ) )
		end
		LWF_ScrollingDDL_PopUp.ShowList = function()
			LWF_ScrollingDDL_PopUp.SetScroll( 1 )
			LWF_ScrollingDDL_PopUp:SetHidden( false )
		end
		LWF_ScrollingDDL_PopUp.ScrollUp = function()
			LWF_ScrollingDDL_PopUp.scrollPosition = LWF_ScrollingDDL_PopUp.scrollPosition - 1
			LWF_ScrollingDDL_PopUp.SetScroll( LWF_ScrollingDDL_PopUp.scrollPosition )
		end
		LWF_ScrollingDDL_PopUp.ScrollDown = function()
			LWF_ScrollingDDL_PopUp.scrollPosition = LWF_ScrollingDDL_PopUp.scrollPosition + 1
			LWF_ScrollingDDL_PopUp.SetScroll( LWF_ScrollingDDL_PopUp.scrollPosition )
		end
		return LWF_ScrollingDDL_PopUp
	end

	LWF4.UI.StandardDDL = {}
	function LWF4.UI.StandardDDL:Create( name, parent, data, selected, dontChangeBase, callBack, scrollSupport )
		LWF4.__hydrate()
		local combo = wm:CreateControlFromVirtual( parent:GetName()..name, parent , "ZO_StatsDropdownRow" )
		combo:SetAnchor(CENTER)
		combo:GetNamedChild("Dropdown"):SetWidth(100)

		combo.data = data
		combo.selected = combo.name
		combo.selected:SetFont("ZoFontGame")
		combo.dropdown = combo.dropdown
		combo.dropdown:SetFont("ZoFontGame")
		if selected then combo.dropdown:SetSelectedItem(selected) end

		combo.dropdown.OnSelect = function(self,value)
			if dontChangeBase and selected then combo.dropdown:SetSelectedItem(selected) end
			callBack( value )
		end

		if scrollSupport then
			local clickBait = combo:GetNamedChild("DropdownOpenDropdown")
			clickBait:SetHandler( "OnClicked", function()
				if LWF_ScrollingDDL_PopUp then
					if not LWF_ScrollingDDL_PopUp:IsHidden() then
						LWF_ScrollingDDL_PopUp:SetParent( LWF_ScrollingDDL_PopUp_HideAway )
						LWF_ScrollingDDL_PopUp:SetHidden( true )
						return
					end
				end
				local dd = combo:GetNamedChild("Dropdown")
				LWF4.UI.ScrollingDDL()
				LWF_ScrollingDDL_PopUp:SetParent( dd )
				LWF_ScrollingDDL_PopUp:ClearAnchors()
				LWF_ScrollingDDL_PopUp:SetAnchor( TOP, dd, BOTTOM, 0, -5 )
				LWF_ScrollingDDL_PopUp.SetCallBack( callBack )
				LWF_ScrollingDDL_PopUp.SetListData( data )
				LWF_ScrollingDDL_PopUp.ShowList()
			end )
		else
			for i = 1,#data do
				local entry = combo.dropdown:CreateItemEntry(data[i],combo.dropdown.OnSelect)
				combo.dropdown:AddItem(entry)
			end
		end
		return combo
	end

	LWF4.UI.__structured = true
end
lwf4.__hydrate = function()
	if not LWF4 then return end
	if LWF4.data.__hydrated then return end

	local kPairs = function(t, f)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
			table.sort(a, f)
			local i = 0
			local iter = function ()
				i = i + 1
				if a[i] == nil then return nil
				else return a[i], t[a[i]]
			end
		end
		return iter
	end

	LWF4.LAM = LibAddonMenu2 -- LibStub("LibAddonMenu-2.0")

	LWF4.data.ChatChannels = {
		p = { channel = CHAT_CHANNEL_PARTY, channelDescr = "CHAT_CHANNEL_PARTY" },
		party = { channel = CHAT_CHANNEL_PARTY, channelDescr = "CHAT_CHANNEL_PARTY" },
		em = { channel = CHAT_CHANNEL_EMOTE, channelDescr = "CHAT_CHANNEL_EMOTE" },
		emote = { channel = CHAT_CHANNEL_EMOTE, channelDescr = "CHAT_CHANNEL_EMOTE" },
		s = { channel = CHAT_CHANNEL_SAY, channelDescr = "CHAT_CHANNEL_SAY" },
		say = { channel = CHAT_CHANNEL_SAY, channelDescr = "CHAT_CHANNEL_SAY" },
		g1 = { channel = CHAT_CHANNEL_GUILD_1, channelDescr = "CHAT_CHANNEL_GUILD_1" },
		g2 = { channel = CHAT_CHANNEL_GUILD_2, channelDescr = "CHAT_CHANNEL_GUILD_2" },
		g3 = { channel = CHAT_CHANNEL_GUILD_3, channelDescr = "CHAT_CHANNEL_GUILD_3" },
		g4 = { channel = CHAT_CHANNEL_GUILD_4, channelDescr = "CHAT_CHANNEL_GUILD_4" },
		g5 = { channel = CHAT_CHANNEL_GUILD_5, channelDescr = "CHAT_CHANNEL_GUILD_5" },
		o1 = { channel = CHAT_CHANNEL_OFFICER_1, channelDescr = "CHAT_CHANNEL_OFFICER_1" },
		o2 = { channel = CHAT_CHANNEL_OFFICER_2, channelDescr = "CHAT_CHANNEL_OFFICER_2" },
		o3 = { channel = CHAT_CHANNEL_OFFICER_3, channelDescr = "CHAT_CHANNEL_OFFICER_3" },
		o4 = { channel = CHAT_CHANNEL_OFFICER_4, channelDescr = "CHAT_CHANNEL_OFFICER_4" },
		o5 = { channel = CHAT_CHANNEL_OFFICER_5, channelDescr = "CHAT_CHANNEL_OFFICER_5" },
		guild1 = { channel = CHAT_CHANNEL_GUILD_1, channelDescr = "CHAT_CHANNEL_GUILD_1" },
		guild2 = { channel = CHAT_CHANNEL_GUILD_2, channelDescr = "CHAT_CHANNEL_GUILD_2" },
		guild3 = { channel = CHAT_CHANNEL_GUILD_3, channelDescr = "CHAT_CHANNEL_GUILD_3" },
		guild4 = { channel = CHAT_CHANNEL_GUILD_4, channelDescr = "CHAT_CHANNEL_GUILD_4" },
		guild5 = { channel = CHAT_CHANNEL_GUILD_5, channelDescr = "CHAT_CHANNEL_GUILD_5" },
		officer1 = { channel = CHAT_CHANNEL_OFFICER_1, channelDescr = "CHAT_CHANNEL_OFFICER_1" },
		officer2 = { channel = CHAT_CHANNEL_OFFICER_2, channelDescr = "CHAT_CHANNEL_OFFICER_2" },
		officer3 = { channel = CHAT_CHANNEL_OFFICER_3, channelDescr = "CHAT_CHANNEL_OFFICER_3" },
		officer4 = { channel = CHAT_CHANNEL_OFFICER_4, channelDescr = "CHAT_CHANNEL_OFFICER_4" },
		officer5 = { channel = CHAT_CHANNEL_OFFICER_5, channelDescr = "CHAT_CHANNEL_OFFICER_5" },
		z = { channel = CHAT_CHANNEL_ZONE, channelDescr = "CHAT_CHANNEL_ZONE" },
		zone = { channel = CHAT_CHANNEL_ZONE, channelDescr = "CHAT_CHANNEL_ZONE" },
		y = { channel = CHAT_CHANNEL_YELL, channelDescr = "CHAT_CHANNEL_YELL" },
		yell = { channel = CHAT_CHANNEL_YELL, channelDescr = "CHAT_CHANNEL_YELL" },
	}

	LWF4.data.TextAlign = {
		["h"] = {
			["left"]	= TEXT_ALIGN_LEFT,
			["center"]	= TEXT_ALIGN_CENTER,
			["right"]	= TEXT_ALIGN_RIGHT,
		},
		["v"] = {
			["top"]		= TEXT_ALIGN_TOP,
			["center"]	= TEXT_ALIGN_CENTER,
			["bottom"]	= TEXT_ALIGN_BOTTOM,
		},
	}
	for k,v in pairs(LWF4.data.TextAlign["h"]) do LWF4.data.TextAlign["h"][string.upper(k)] = v end
	for k,v in pairs(LWF4.data.TextAlign["v"]) do LWF4.data.TextAlign["v"][string.upper(k)] = v end
	LWF4.data.TextAlign["H"] = LWF4.data.TextAlign["h"]
	LWF4.data.TextAlign["V"] = LWF4.data.TextAlign["v"]

	LWF4.data.EquipSlot = {
        ["EQUIP_SLOT_BACKUP_MAIN"] 	    = EQUIP_SLOT_BACKUP_MAIN,
		["EQUIP_SLOT_BACKUP_OFF"] 	    = EQUIP_SLOT_BACKUP_OFF,
        ["EQUIP_SLOT_BACKUP_POISON"]    = EQUIP_SLOT_BACKUP_POISON,
        ["EQUIP_SLOT_CHEST"] 		    = EQUIP_SLOT_CHEST,
        ["EQUIP_SLOT_CLASS1"] 		    = EQUIP_SLOT_CLASS1,
        ["EQUIP_SLOT_CLASS2"] 		    = EQUIP_SLOT_CLASS2,
        ["EQUIP_SLOT_CLASS3"] 		    = EQUIP_SLOT_CLASS3,
        ["EQUIP_SLOT_COSTUME"]          = EQUIP_SLOT_COSTUME,
        ["EQUIP_SLOT_FEET"] 		    = EQUIP_SLOT_FEET,
        ["EQUIP_SLOT_HAND"] 		    = EQUIP_SLOT_HAND,
        ["EQUIP_SLOT_HEAD"] 		    = EQUIP_SLOT_HEAD,
		["EQUIP_SLOT_LEGS"] 		    = EQUIP_SLOT_LEGS,
        ["EQUIP_SLOT_MAIN_HAND"] 	    = EQUIP_SLOT_MAIN_HAND,
        ["EQUIP_SLOT_NECK"] 		    = EQUIP_SLOT_NECK,
		["EQUIP_SLOT_NONE"]             = EQUIP_SLOT_NONE,
        ["EQUIP_SLOT_OFF_HAND"] 	    = EQUIP_SLOT_OFF_HAND,
        ["EQUIP_SLOT_POISON"]           = EQUIP_SLOT_POISON,
        ["EQUIP_SLOT_RANGED"]           = EQUIP_SLOT_RANGED,
        ["EQUIP_SLOT_RING1"] 		    = EQUIP_SLOT_RING1,
		["EQUIP_SLOT_RING2"] 		    = EQUIP_SLOT_RING2,
        ["EQUIP_SLOT_SHOULDERS"] 	    = EQUIP_SLOT_SHOULDERS,
		["EQUIP_SLOT_WAIST"] 		    = EQUIP_SLOT_WAIST,
		["EQUIP_SLOT_WRIST"] 		    = EQUIP_SLOT_WRIST,

	}
	LWF4.data.EquipSlotBagSlot = {
		["EQUIP_SLOT_BACKUP_MAIN"] 	    = 20,
		["EQUIP_SLOT_BACKUP_OFF"] 	    = 21,
        ["EQUIP_SLOT_BACKUP_POISON"]    = 14,
		["EQUIP_SLOT_CHEST"] 		    = 2,
        ["EQUIP_SLOT_CLASS1"] 		    = 17,
        ["EQUIP_SLOT_CLASS2"] 		    = 18,
        ["EQUIP_SLOT_CLASS3"] 		    = 19,
        ["EQUIP_SLOT_COSTUME"]          = 10,
		["EQUIP_SLOT_FEET"] 		    = 9,
		["EQUIP_SLOT_HAND"] 		    = 16,
		["EQUIP_SLOT_HEAD"] 		    = 0,
		["EQUIP_SLOT_LEGS"] 		    = 8,
		["EQUIP_SLOT_MAIN_HAND"] 	    = 4,
		["EQUIP_SLOT_NECK"] 		    = 1,
		["EQUIP_SLOT_OFF_HAND"] 	    = 5,
        ["EQUIP_SLOT_POISON"]           = 13,
        ["EQUIP_SLOT_RANGED"]           = 15,
		["EQUIP_SLOT_RING1"] 		    = 11,
		["EQUIP_SLOT_RING2"] 		    = 12,
		["EQUIP_SLOT_SHOULDERS"] 	    = 3,
		["EQUIP_SLOT_WAIST"] 		    = 6,
		["EQUIP_SLOT_WRIST"] 		    = 7,

	}
	for descr,slot in pairs(LWF4.data.EquipSlotBagSlot) do LWF4.data.EquipSlotDescrByBagSlot[slot] = descr end
	for descr,slot in pairs(LWF4.data.EquipSlot) do LWF4.data.EquipBagSlot[slot] = LWF4.data.EquipSlotBagSlot[descr] end

	LWF4.data.GameImages = {
		"/esoui/art/achievements/achievements_iconbg.dds",
        "/esoui/art/achievements/achievements_reward_earned.dds",
        "/esoui/art/achievements/achievements_reward_unearned.dds",
        "/esoui/art/actionbar/abilityframe64_down.dds",
        "/esoui/art/actionbar/abilityframe64_up.dds",
        "/esoui/art/actionbar/ability_keybindbg.dds",
        "/esoui/art/actionbar/actionbar_bg_1xheight.dds",
        "/esoui/art/actionbar/actionbar_bg_2xheight.dds",
        "/esoui/art/actionbar/actionbar_bg_2xheight_bottom.dds",
        "/esoui/art/actionbar/buff_frame.dds",
        "/esoui/art/actionbar/classbar_bg.dds",
        "/esoui/art/actionbar/debuff_frame.dds",
        "/esoui/art/actionbar/magechamber_firespelloverlay_down.dds",
        "/esoui/art/actionbar/magechamber_firespelloverlay_up.dds",
        "/esoui/art/actionbar/magechamber_icespelloverlay_down.dds",
        "/esoui/art/actionbar/magechamber_icespelloverlay_up.dds",
        "/esoui/art/actionbar/magechamber_lightningspelloverlay_down.dds",
        "/esoui/art/actionbar/magechamber_lightningspelloverlay_up.dds",
        "/esoui/art/actionbar/magechamber_magespelloverlay02_down.dds",
        "/esoui/art/actionbar/magechamber_magespelloverlay02_up.dds",
        "/esoui/art/actionbar/magechamber_magespelloverlay_down.dds",
        "/esoui/art/actionbar/magechamber_magespelloverlay_up.dds",
        "/esoui/art/actionbar/pagination_down_down.dds",
        "/esoui/art/actionbar/pagination_down_over.dds",
        "/esoui/art/actionbar/pagination_down_up.dds",
        "/esoui/art/actionbar/pagination_up_down.dds",
        "/esoui/art/actionbar/pagination_up_over.dds",
        "/esoui/art/actionbar/pagination_up_up.dds",
        "/esoui/art/actionbar/passiveabilityframe_round_down.dds",
        "/esoui/art/actionbar/passiveabilityframe_round_empty.dds",
        "/esoui/art/actionbar/passiveabilityframe_round_locked.dds",
        "/esoui/art/actionbar/passiveabilityframe_round_over.dds",
        "/esoui/art/actionbar/passiveabilityframe_round_up.dds",
        "/esoui/art/actionbar/quickslotbg.dds",
        "/esoui/art/actionbar/ultimatemeter_frame64.dds",
        "/esoui/art/ava/avacapturebar_alliancebadge_aldmeri.dds",
        "/esoui/art/ava/avacapturebar_alliancebadge_daggerfall.dds",
        "/esoui/art/ava/avacapturebar_alliancebadge_ebonheart.dds",
        "/esoui/art/ava/avacapturebar_arrow_capturing.dds",
        "/esoui/art/ava/avacapturebar_arrow_contesting.dds",
        "/esoui/art/ava/avacapturebar_barframe.dds",
        "/esoui/art/ava/avacapturebar_fill_aldmeri.dds",
        "/esoui/art/ava/avacapturebar_fill_capturing_aldmeri.dds",
        "/esoui/art/ava/avacapturebar_fill_capturing_daggerfall.dds",
        "/esoui/art/ava/avacapturebar_fill_capturing_ebonheart.dds",
        "/esoui/art/ava/avacapturebar_fill_contested_aldmeri.dds",
        "/esoui/art/ava/avacapturebar_fill_contested_daggerfall.dds",
        "/esoui/art/ava/avacapturebar_fill_contested_ebonheart.dds",
        "/esoui/art/ava/avacapturebar_fill_daggerfall.dds",
        "/esoui/art/ava/avacapturebar_fill_ebonheart.dds",
        "/esoui/art/ava/avacapturebar_midpointdivider.dds",
        "/esoui/art/ava/avacapturebar_point_aldmeri.dds",
        "/esoui/art/ava/avacapturebar_point_daggerfall.dds",
        "/esoui/art/ava/avacapturebar_point_ebonheart.dds",
        "/esoui/art/ava/overview_icon_underdog_population.dds",
        "/esoui/art/ava/overview_icon_underdog_score.dds",
        "/esoui/art/bank/bank_purchaseover.dds",
        "/esoui/art/bank/bank_tabicon_deposit_down.dds",
        "/esoui/art/bank/bank_tabicon_deposit_over.dds",
        "/esoui/art/bank/bank_tabicon_deposit_up.dds",
        "/esoui/art/bank/bank_tabicon_withdraw_down.dds",
        "/esoui/art/bank/bank_tabicon_withdraw_over.dds",
        "/esoui/art/bank/bank_tabicon_withdraw_up.dds",
        "/esoui/art/bossbar/bossbar_bracket_left.dds",
        "/esoui/art/bossbar/bossbar_bracket_right.dds",
        "/esoui/art/buttons/accept_down.dds",
        "/esoui/art/buttons/accept_over.dds",
        "/esoui/art/buttons/accept_up.dds",
        "/esoui/art/buttons/blade_closed_down.dds",
        "/esoui/art/buttons/blade_closed_up.dds",
        "/esoui/art/buttons/blade_disabled.dds",
        "/esoui/art/buttons/blade_mouseover.dds",
        "/esoui/art/buttons/blade_open_down.dds",
        "/esoui/art/buttons/blade_open_up.dds",
        "/esoui/art/buttons/cancel_down.dds",
        "/esoui/art/buttons/cancel_over.dds",
        "/esoui/art/buttons/cancel_up.dds",
        "/esoui/art/buttons/checkbox_checked_disabled.dds",
        "/esoui/art/buttons/checkbox_indeterminate.dds",
        "/esoui/art/buttons/clearslot_disabled.dds",
        "/esoui/art/buttons/clearslot_down.dds",
        "/esoui/art/buttons/clearslot_up.dds",
        "/esoui/art/buttons/decline_down.dds",
        "/esoui/art/buttons/decline_over.dds",
        "/esoui/art/buttons/decline_up.dds",
        "/esoui/art/buttons/dropbox_arrow_disabled.dds",
        "/esoui/art/buttons/edit_cancel_down.dds",
        "/esoui/art/buttons/edit_cancel_over.dds",
        "/esoui/art/buttons/edit_cancel_up.dds",
        "/esoui/art/buttons/edit_disabled.dds",
        "/esoui/art/buttons/edit_down.dds",
        "/esoui/art/buttons/edit_over.dds",
        "/esoui/art/buttons/edit_save_disabled.dds",
        "/esoui/art/buttons/edit_save_down.dds",
        "/esoui/art/buttons/edit_save_over.dds",
        "/esoui/art/buttons/edit_save_up.dds",
        "/esoui/art/buttons/edit_up.dds",
        "/esoui/art/buttons/generic_highlight.dds",
        "/esoui/art/buttons/info_disabled.dds",
        "/esoui/art/buttons/info_down.dds",
        "/esoui/art/buttons/info_over.dds",
        "/esoui/art/buttons/info_up.dds",
        "/esoui/art/buttons/leftarrow_disabled.dds",
        "/esoui/art/buttons/left_mousedown.dds",
        "/esoui/art/buttons/left_normal.dds",
        "/esoui/art/buttons/maximize_mousedown.dds",
        "/esoui/art/buttons/maximize_normal.dds",
        "/esoui/art/buttons/minimize_mousedown.dds",
        "/esoui/art/buttons/minimize_normal.dds",
        "/esoui/art/buttons/minmax_mouseover.dds",
        "/esoui/art/buttons/minus_disabled.dds",
        "/esoui/art/buttons/minus_down.dds",
        "/esoui/art/buttons/minus_over.dds",
        "/esoui/art/buttons/minus_up.dds",
        "/esoui/art/buttons/pinned_mousedown.dds",
        "/esoui/art/buttons/pinned_mouseover.dds",
        "/esoui/art/buttons/pinned_normal.dds",
        "/esoui/art/buttons/plus_disabled.dds",
        "/esoui/art/buttons/plus_down.dds",
        "/esoui/art/buttons/plus_over.dds",
        "/esoui/art/buttons/plus_up.dds",
        "/esoui/art/buttons/pointsminus_disabled.dds",
        "/esoui/art/buttons/pointsminus_down.dds",
        "/esoui/art/buttons/pointsminus_over.dds",
        "/esoui/art/buttons/pointsminus_up.dds",
        "/esoui/art/buttons/pointsplus_disabled.dds",
        "/esoui/art/buttons/pointsplus_down.dds",
        "/esoui/art/buttons/pointsplus_highlight.dds",
        "/esoui/art/buttons/pointsplus_over.dds",
        "/esoui/art/buttons/pointsplus_up.dds",
        "/esoui/art/buttons/radiobuttondisableddown.dds",
        "/esoui/art/buttons/rightarrow_disabled.dds",
        "/esoui/art/buttons/right_mousedown.dds",
        "/esoui/art/buttons/right_normal.dds",
        "/esoui/art/buttons/searchbutton_disabled.dds",
        "/esoui/art/buttons/smoothsliderbutton_down.dds",
        "/esoui/art/buttons/smoothsliderbutton_over.dds",
        "/esoui/art/buttons/smoothsliderbutton_selected.dds",
        "/esoui/art/buttons/smoothsliderbutton_up.dds",
        "/esoui/art/buttons/swatchframe_down.dds",
        "/esoui/art/buttons/swatchframe_over.dds",
        "/esoui/art/buttons/swatchframe_selected.dds",
        "/esoui/art/buttons/swatchframe_selected_disabled.dds",
        "/esoui/art/buttons/swatchframe_up.dds",
        "/esoui/art/buttons/switch_disabled.dds",
        "/esoui/art/buttons/switch_down.dds",
        "/esoui/art/buttons/switch_up.dds",
        "/esoui/art/buttons/unpinned_mousedown.dds",
        "/esoui/art/buttons/unpinned_mouseover.dds",
        "/esoui/art/buttons/unpinned_normal.dds",
        "/esoui/art/buttons/gamepad/ps4/leftarrow_down.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_circle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_circle_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpad.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpaddown.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpaddown_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadleft.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadleft_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadright.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadright_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadup.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_dpadup_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1circle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1dpadleft.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1r1.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1r2.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1rs_press.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1rs_right.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1square.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1triangle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1x.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l1_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2circle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2r2.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2square.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2triangle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2x.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_l2_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_leftarrow_down_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_lsrs.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_lsrs_press.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_down.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_left.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_press.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_right.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_ls_up.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_options.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1circle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1square.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1triangle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1x.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r1_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r2.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_r2_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rightarrow_down_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_down.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_left.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_press.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_right.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_rs_up.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_share.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_square.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_square_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_circle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_down.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_left.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_leftright.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_lefttoright.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_right.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_up.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_trackpad_updown.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_triangle_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_x.dds",
        "/esoui/art/buttons/gamepad/ps4/nav_ps4_x_hold.dds",
        "/esoui/art/buttons/gamepad/ps4/rightarrow_down.dds",
        "/esoui/art/buttons/gamepad/xbox/leftarrow_down.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1circle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1dpadleft.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1r2.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1rs_right.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1square.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1triangle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l1x.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l2circle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l2square.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l2triangle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_l2x.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_lsrs_press.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_r1circle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_r1square.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_r1triangle.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_ps4_r1x.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_a.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_a_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_b_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpad.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpaddown.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpaddown_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadleft.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadleft_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadright.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadright_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadup.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_dpadup_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_du.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lba.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbdpadleft.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbrb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbrs_press.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbrs_right.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbrt.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lbx.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lby.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lb_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_leftarrow_down_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lsrs.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lsrs_press.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_down.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_left.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_press.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_right.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ls_up.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lt.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lta.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ltb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ltrt.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_ltx.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lty.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_lt_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rba.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rbb.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rbx.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rby.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rb_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rightarrow_down_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_down.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_left.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_menu.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_press.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_right.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rs_up.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rt.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_rt_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_view.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_x_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_y.dds",
        "/esoui/art/buttons/gamepad/xbox/nav_xbone_y_hold.dds",
        "/esoui/art/buttons/gamepad/xbox/rightarrow_down.dds",
        "/esoui/art/cadwell/cadwell_indexicon_gold_disabled.dds",
        "/esoui/art/cadwell/cadwell_indexicon_gold_down.dds",
        "/esoui/art/cadwell/cadwell_indexicon_gold_over.dds",
        "/esoui/art/cadwell/cadwell_indexicon_gold_up.dds",
        "/esoui/art/cadwell/cadwell_indexicon_silver_disabled.dds",
        "/esoui/art/cadwell/cadwell_indexicon_silver_down.dds",
        "/esoui/art/cadwell/cadwell_indexicon_silver_over.dds",
        "/esoui/art/cadwell/cadwell_indexicon_silver_up.dds",
        "/esoui/art/cadwell/check.dds",
        "/esoui/art/cadwell/checkboxicon_checked.dds",
        "/esoui/art/cadwell/checkboxicon_unchecked.dds",
        "/esoui/art/campaign/campaignbonus_emporershipicon.dds",
        "/esoui/art/campaign/campaignbonus_keepicon.dds",
        "/esoui/art/campaign/campaignbonus_scrollicon.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_ad.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_ad_over.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_dc.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_dc_over.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_ep.dds",
        "/esoui/art/campaign/campaignbrowser_columnheader_ep_over.dds",
        "/esoui/art/campaign/campaignbrowser_divider_short.dds",
        "/esoui/art/campaign/campaignbrowser_friends.dds",
        "/esoui/art/campaign/campaignbrowser_fullpop.dds",
        "/esoui/art/campaign/campaignbrowser_group.dds",
        "/esoui/art/campaign/campaignbrowser_guestcampaign.dds",
        "/esoui/art/campaign/campaignbrowser_guild.dds",
        "/esoui/art/campaign/campaignbrowser_hipop.dds",
        "/esoui/art/campaign/campaignbrowser_homecampaign.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_hardcore_down.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_hardcore_over.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_hardcore_up.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_normal_down.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_normal_over.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_normal_up.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds",
        "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
        "/esoui/art/campaign/campaignbrowser_listdivider_left.dds",
        "/esoui/art/campaign/campaignbrowser_listdivider_right.dds",
        "/esoui/art/campaign/campaignbrowser_lowpop.dds",
        "/esoui/art/campaign/campaignbrowser_medpop.dds",
        "/esoui/art/campaign/campaignbrowser_queued.dds",
        "/esoui/art/campaign/campaignbrowser_ready.dds",
        "/esoui/art/campaign/campaign_tabicon_browser_down.dds",
        "/esoui/art/campaign/campaign_tabicon_browser_over.dds",
        "/esoui/art/campaign/campaign_tabicon_browser_up.dds",
        "/esoui/art/campaign/campaign_tabicon_history_down.dds",
        "/esoui/art/campaign/campaign_tabicon_history_over.dds",
        "/esoui/art/campaign/campaign_tabicon_history_up.dds",
        "/esoui/art/campaign/campaign_tabicon_leaderboard_down.dds",
        "/esoui/art/campaign/campaign_tabicon_leaderboard_over.dds",
        "/esoui/art/campaign/campaign_tabicon_leaderboard_up.dds",
        "/esoui/art/campaign/campaign_tabicon_summary_down.dds",
        "/esoui/art/campaign/campaign_tabicon_summary_over.dds",
        "/esoui/art/campaign/campaign_tabicon_summary_up.dds",
        "/esoui/art/campaign/emporer_playerbg_left.dds",
        "/esoui/art/campaign/emporer_playerbg_right.dds",
        "/esoui/art/campaign/leaderboard_meddivider_left.dds",
        "/esoui/art/campaign/leaderboard_meddivider_right.dds",
        "/esoui/art/campaign/leaderboard_playerhighlight_left.dds",
        "/esoui/art/campaign/leaderboard_playerhighlight_right.dds",
        "/esoui/art/campaign/leaderboard_top100banner.dds",
        "/esoui/art/campaign/leaderboard_top20banner.dds",
        "/esoui/art/campaign/leaderboard_top50banner.dds",
        "/esoui/art/campaign/overview_allianceicon_aldmeri.dds",
        "/esoui/art/campaign/overview_allianceicon_daggefall.dds",
        "/esoui/art/campaign/overview_allianceicon_ebonheart.dds",
        "/esoui/art/campaign/overview_indexicon_bonus_disabled.dds",
        "/esoui/art/campaign/overview_indexicon_bonus_down.dds",
        "/esoui/art/campaign/overview_indexicon_bonus_over.dds",
        "/esoui/art/campaign/overview_indexicon_bonus_up.dds",
        "/esoui/art/campaign/overview_indexicon_emperor_disabled.dds",
        "/esoui/art/campaign/overview_indexicon_emperor_down.dds",
        "/esoui/art/campaign/overview_indexicon_emperor_over.dds",
        "/esoui/art/campaign/overview_indexicon_emperor_up.dds",
        "/esoui/art/campaign/overview_indexicon_scoring_disabled.dds",
        "/esoui/art/campaign/overview_indexicon_scoring_down.dds",
        "/esoui/art/campaign/overview_indexicon_scoring_over.dds",
        "/esoui/art/campaign/overview_indexicon_scoring_up.dds",
        "/esoui/art/campaign/overview_keepicon_aldmeri.dds",
        "/esoui/art/campaign/overview_keepicon_daggefall.dds",
        "/esoui/art/campaign/overview_keepicon_ebonheart.dds",
        "/esoui/art/campaign/overview_outposticon_aldmeri.dds",
        "/esoui/art/campaign/overview_outposticon_daggefall.dds",
        "/esoui/art/campaign/overview_outposticon_ebonheart.dds",
        "/esoui/art/campaign/overview_resourcesicon_aldmeri.dds",
        "/esoui/art/campaign/overview_resourcesicon_daggefall.dds",
        "/esoui/art/campaign/overview_resourcesicon_ebonheart.dds",
        "/esoui/art/campaign/overview_rewardprogbar_left.dds",
        "/esoui/art/campaign/overview_rewardprogbar_right.dds",
        "/esoui/art/campaign/overview_scoringbg_aldmeri_left.dds",
        "/esoui/art/campaign/overview_scoringbg_aldmeri_right.dds",
        "/esoui/art/campaign/overview_scoringbg_daggerfall_left.dds",
        "/esoui/art/campaign/overview_scoringbg_daggerfall_right.dds",
        "/esoui/art/campaign/overview_scoringbg_ebonheart_left.dds",
        "/esoui/art/campaign/overview_scoringbg_ebonheart_right.dds",
        "/esoui/art/campaign/overview_scrollicon_aldmeri.dds",
        "/esoui/art/campaign/overview_scrollicon_daggefall.dds",
        "/esoui/art/campaign/overview_scrollicon_ebonheart.dds",
        "/esoui/art/champion/champion_clouds.dds",
        "/esoui/art/champion/champion_colorclouds.dds",
        "/esoui/art/champion/champion_constellations.dds",
        "/esoui/art/champion/champion_starclusterslarge.dds",
        "/esoui/art/champion/champion_starclustersmedium.dds",
        "/esoui/art/champion/champion_starclusterssmall.dds",
        "/esoui/art/champion/champion_staroff.dds",
        "/esoui/art/champion/champion_staron.dds",
        "/esoui/art/charactercreate/charactercreate_accessory_down.dds",
        "/esoui/art/charactercreate/charactercreate_accessory_over.dds",
        "/esoui/art/charactercreate/charactercreate_accessory_up.dds",
        "/esoui/art/charactercreate/charactercreate_altmericon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_argonianicon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_audio_down.dds",
        "/esoui/art/charactercreate/charactercreate_audio_over.dds",
        "/esoui/art/charactercreate/charactercreate_audio_up.dds",
        "/esoui/art/charactercreate/charactercreate_bodyicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_bodyicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_bodyicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_bosmericon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_bretonicon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_classicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_classicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_classicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_dunmericon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_faceicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_faceicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_faceicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_femaleicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_femaleicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_femaleicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_khajiiticon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_leftarrow_down.dds",
        "/esoui/art/charactercreate/charactercreate_leftarrow_over.dds",
        "/esoui/art/charactercreate/charactercreate_leftarrow_up.dds",
        "/esoui/art/charactercreate/charactercreate_maleicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_maleicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_maleicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_nordicon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_raceicon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_raceicon_down.dds",
        "/esoui/art/charactercreate/charactercreate_raceicon_over.dds",
        "/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
        "/esoui/art/charactercreate/charactercreate_redguardicon_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_rightarrow_down.dds",
        "/esoui/art/charactercreate/charactercreate_rightarrow_over.dds",
        "/esoui/art/charactercreate/charactercreate_rightarrow_up.dds",
        "/esoui/art/charactercreate/charactercreate_zoom+_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_zoom+_down.dds",
        "/esoui/art/charactercreate/charactercreate_zoom+_over.dds",
        "/esoui/art/charactercreate/charactercreate_zoom+_up.dds",
        "/esoui/art/charactercreate/charactercreate_zoom-_disabled.dds",
        "/esoui/art/charactercreate/charactercreate_zoom-_down.dds",
        "/esoui/art/charactercreate/charactercreate_zoom-_over.dds",
        "/esoui/art/charactercreate/charactercreate_zoom-_up.dds",
        "/esoui/art/charactercreate/charactercreate_zoom_over.dds",
        "/esoui/art/charactercreate/rotate_left_down.dds",
        "/esoui/art/charactercreate/rotate_left_over.dds",
        "/esoui/art/charactercreate/rotate_left_up.dds",
        "/esoui/art/charactercreate/rotate_right_down.dds",
        "/esoui/art/charactercreate/rotate_right_over.dds",
        "/esoui/art/charactercreate/rotate_right_up.dds",
        "/esoui/art/charactercreate/selectortriangle.dds",
        "/esoui/art/charactercreate/selectortriangle_disabled.dds",
        "/esoui/art/charactercreate/triangle_selector_pip.dds",
        "/esoui/art/charactercreate/triangle_selector_pip_disabled.dds",
        "/esoui/art/charactercreate/triangle_selector_pip_glow.dds",
        "/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds",
        "/esoui/art/charactercreate/unavailable_overlay.dds",
        "/esoui/art/charactercreate/windowdivider.dds",
        "/esoui/art/characterwindow/alliancebadge_aldmeri.dds",
        "/esoui/art/characterwindow/alliancebadge_daggerfall.dds",
        "/esoui/art/characterwindow/alliancebadge_ebonheart.dds",
        "/esoui/art/characterwindow/characterwindow_leftsidebg_bottom.dds",
        "/esoui/art/characterwindow/characterwindow_leftsidebg_top.dds",
        "/esoui/art/characterwindow/characterwindow_leftside_divider.dds",
        "/esoui/art/characterwindow/charsheet_guildtab_icon_inactive.dds",
        "/esoui/art/characterwindow/charsheet_statstab_icon_inactive.dds",
        "/esoui/art/characterwindow/gearslot_belt.dds",
        "/esoui/art/characterwindow/gearslot_chest.dds",
        "/esoui/art/characterwindow/gearslot_costume.dds",
        "/esoui/art/characterwindow/gearslot_feet.dds",
        "/esoui/art/characterwindow/gearslot_hands.dds",
        "/esoui/art/characterwindow/gearslot_head.dds",
        "/esoui/art/characterwindow/gearslot_legs.dds",
        "/esoui/art/characterwindow/gearslot_mainhand.dds",
        "/esoui/art/characterwindow/gearslot_neck.dds",
        "/esoui/art/characterwindow/gearslot_offhand.dds",
        "/esoui/art/characterwindow/gearslot_over.dds",
        "/esoui/art/characterwindow/gearslot_quickslot.dds",
        "/esoui/art/characterwindow/gearslot_ring.dds",
        "/esoui/art/characterwindow/gearslot_selected.dds",
        "/esoui/art/characterwindow/gearslot_shoulders.dds",
        "/esoui/art/characterwindow/gearslot_tabard.dds",
        "/esoui/art/characterwindow/sigil_armor.dds",
        "/esoui/art/characterwindow/sigil_health.dds",
        "/esoui/art/characterwindow/sigil_stamina.dds",
        "/esoui/art/characterwindow/swap_button_disabled.dds",
        "/esoui/art/characterwindow/swap_button_down.dds",
        "/esoui/art/characterwindow/swap_button_over.dds",
        "/esoui/art/characterwindow/swap_button_up.dds",
        "/esoui/art/characterwindow/swap_lock.dds",
        "/esoui/art/characterwindow/weaponswap_disabled.dds",
        "/esoui/art/characterwindow/weaponswap_down.dds",
        "/esoui/art/characterwindow/weaponswap_locked.dds",
        "/esoui/art/characterwindow/weaponswap_over.dds",
        "/esoui/art/characterwindow/weaponswap_up.dds",
        "/esoui/art/characterwindow/xpbar_left.dds",
        "/esoui/art/characterwindow/xpbar_right.dds",
        "/esoui/art/chatwindow/chat_addtab_disabled.dds",
        "/esoui/art/chatwindow/chat_addtab_down.dds",
        "/esoui/art/chatwindow/chat_addtab_over.dds",
        "/esoui/art/chatwindow/chat_addtab_up.dds",
        "/esoui/art/chatwindow/chat_bg_center.dds",
        "/esoui/art/chatwindow/chat_bg_edge.dds",
        "/esoui/art/chatwindow/chat_cs_down.dds",
        "/esoui/art/chatwindow/chat_cs_echo.dds",
        "/esoui/art/chatwindow/chat_cs_glow.dds",
        "/esoui/art/chatwindow/chat_cs_over.dds",
        "/esoui/art/chatwindow/chat_cs_up.dds",
        "/esoui/art/chatwindow/chat_friendsonline_down.dds",
        "/esoui/art/chatwindow/chat_friendsonline_over.dds",
        "/esoui/art/chatwindow/chat_friendsonline_up.dds",
        "/esoui/art/chatwindow/chat_mail_down.dds",
        "/esoui/art/chatwindow/chat_mail_glow.dds",
        "/esoui/art/chatwindow/chat_mail_over.dds",
        "/esoui/art/chatwindow/chat_mail_up.dds",
        "/esoui/art/chatwindow/chat_minimized_mungebg.dds",
        "/esoui/art/chatwindow/chat_minimized_mungebg_highlight.dds",
        "/esoui/art/chatwindow/chat_notification_burst.dds",
        "/esoui/art/chatwindow/chat_notification_disabled.dds",
        "/esoui/art/chatwindow/chat_notification_down.dds",
        "/esoui/art/chatwindow/chat_notification_echo.dds",
        "/esoui/art/chatwindow/chat_notification_glow.dds",
        "/esoui/art/chatwindow/chat_notification_over.dds",
        "/esoui/art/chatwindow/chat_notification_up.dds",
        "/esoui/art/chatwindow/chat_options_down.dds",
        "/esoui/art/chatwindow/chat_options_over.dds",
        "/esoui/art/chatwindow/chat_options_up.dds",
        "/esoui/art/chatwindow/chat_overflowarrow_down.dds",
        "/esoui/art/chatwindow/chat_overflowarrow_over.dds",
        "/esoui/art/chatwindow/chat_overflowarrow_up.dds",
        "/esoui/art/chatwindow/chat_scrollbar_track.dds",
        "/esoui/art/chatwindow/chat_thumb.dds",
        "/esoui/art/chatwindow/chat_thumb_disabled.dds",
        "/esoui/art/chatwindow/csicon.dds",
        "/esoui/art/chatwindow/maximize_down.dds",
        "/esoui/art/chatwindow/maximize_over.dds",
        "/esoui/art/chatwindow/maximize_up.dds",
        "/esoui/art/chatwindow/minimize_down.dds",
        "/esoui/art/chatwindow/minimize_over.dds",
        "/esoui/art/chatwindow/minimize_up.dds",
        "/esoui/art/chatwindow/tabicon_chatcolors_inactive.dds",
        "/esoui/art/chatwindow/tabicon_chatoptions_inactive.dds",
        "/esoui/art/compass/area2frameanim_assisted_center.dds",
        "/esoui/art/compass/area2frameanim_assisted_endcap.dds",
        "/esoui/art/compass/area2frameanim_centers.dds",
        "/esoui/art/compass/area2frameanim_standard_center.dds",
        "/esoui/art/compass/area2frameanim_standard_endcap.dds",
        "/esoui/art/compass/areapin2frame_ends.dds",
        "/esoui/art/compass/ava_3way.dds",
        "/esoui/art/compass/ava_aldmerivdaggerfall.dds",
        "/esoui/art/compass/ava_aldmerivebonheart.dds",
        "/esoui/art/compass/ava_artifactgate_aldmeri_closed.dds",
        "/esoui/art/compass/ava_artifactgate_aldmeri_open.dds",
        "/esoui/art/compass/ava_artifactgate_daggerfall_closed.dds",
        "/esoui/art/compass/ava_artifactgate_daggerfall_open.dds",
        "/esoui/art/compass/ava_artifactgate_ebonheart_closed.dds",
        "/esoui/art/compass/ava_artifactgate_ebonheart_open.dds",
        "/esoui/art/compass/ava_artifacttemple_aldmeri.dds",
        "/esoui/art/compass/ava_artifacttemple_daggerfall.dds",
        "/esoui/art/compass/ava_artifacttemple_ebonheart.dds",
        "/esoui/art/compass/ava_artifact_almaruma.dds",
        "/esoui/art/compass/ava_artifact_altadoon.dds",
        "/esoui/art/compass/ava_artifact_chim.dds",
        "/esoui/art/compass/ava_artifact_ghartok.dds",
        "/esoui/art/compass/ava_artifact_mnem.dds",
        "/esoui/art/compass/ava_artifact_nimohk.dds",
        "/esoui/art/compass/ava_attackburst_64.dds",
        "/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds",
        "/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds",
        "/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds",
        "/esoui/art/compass/ava_cemetary_aldmeri.dds",
        "/esoui/art/compass/ava_cemetary_daggerfall.dds",
        "/esoui/art/compass/ava_cemetary_ebonheart.dds",
        "/esoui/art/compass/ava_daggerfallvaldmeri.dds",
        "/esoui/art/compass/ava_daggerfallvebonheart.dds",
        "/esoui/art/compass/ava_ebonheartvaldmeri.dds",
        "/esoui/art/compass/ava_ebonheartvdaggerfall.dds",
        "/esoui/art/compass/ava_farm_aldmeri.dds",
        "/esoui/art/compass/ava_farm_daggerfall.dds",
        "/esoui/art/compass/ava_farm_ebonheart.dds",
        "/esoui/art/compass/ava_farm_neutral.dds",
        "/esoui/art/compass/ava_flagaldmeri.dds",
        "/esoui/art/compass/ava_flagattack_aldmeri.dds",
        "/esoui/art/compass/ava_flagattack_daggerfall.dds",
        "/esoui/art/compass/ava_flagattack_ebonheart.dds",
        "/esoui/art/compass/ava_flagattack_neutral.dds",
        "/esoui/art/compass/ava_flagbase_aldmeri.dds",
        "/esoui/art/compass/ava_flagbase_daggerfall.dds",
        "/esoui/art/compass/ava_flagbase_ebonheart.dds",
        "/esoui/art/compass/ava_flagbase_neutral.dds",
        "/esoui/art/compass/ava_flagcarrier_aldmeri.dds",
        "/esoui/art/compass/ava_flagcarrier_daggerfall.dds",
        "/esoui/art/compass/ava_flagcarrier_ebonheart.dds",
        "/esoui/art/compass/ava_flagcarrier_neutral.dds",
        "/esoui/art/compass/ava_flagdaggerfall.dds",
        "/esoui/art/compass/ava_flagebonheart.dds",
        "/esoui/art/compass/ava_flagneutral.dds",
        "/esoui/art/compass/ava_largekeep_aldmeri.dds",
        "/esoui/art/compass/ava_largekeep_daggerfall.dds",
        "/esoui/art/compass/ava_largekeep_ebonheart.dds",
        "/esoui/art/compass/ava_largekeep_neutral.dds",
        "/esoui/art/compass/ava_lumbermill_aldmeri.dds",
        "/esoui/art/compass/ava_lumbermill_daggerfall.dds",
        "/esoui/art/compass/ava_lumbermill_ebonheart.dds",
        "/esoui/art/compass/ava_lumbermill_neutral.dds",
        "/esoui/art/compass/ava_mine_aldmeri.dds",
        "/esoui/art/compass/ava_mine_daggerfall.dds",
        "/esoui/art/compass/ava_mine_ebonheart.dds",
        "/esoui/art/compass/ava_mine_neutral.dds",
        "/esoui/art/compass/ava_murderball_aldmeri.dds",
        "/esoui/art/compass/ava_murderball_daggerfall.dds",
        "/esoui/art/compass/ava_murderball_ebonheart.dds",
        "/esoui/art/compass/ava_murderball_neutral.dds",
        "/esoui/art/compass/ava_outpost_aldmeri.dds",
        "/esoui/art/compass/ava_outpost_daggerfall.dds",
        "/esoui/art/compass/ava_outpost_ebonheart.dds",
        "/esoui/art/compass/ava_outpost_neutral.dds",
        "/esoui/art/compass/ava_returnpoint_aldmeri.dds",
        "/esoui/art/compass/ava_returnpoint_daggerfall.dds",
        "/esoui/art/compass/ava_returnpoint_ebonheart.dds",
        "/esoui/art/compass/ava_returnpoint_neutral.dds",
        "/esoui/art/compass/compass.dds",
        "/esoui/art/compass/compass_ava_imperialcitydistrict_aldmeri.dds",
        "/esoui/art/compass/compass_ava_imperialcitydistrict_daggerfall.dds",
        "/esoui/art/compass/compass_ava_imperialcitydistrict_ebonheart.dds",
        "/esoui/art/compass/compass_ava_imperialcitydistrict_neutral.dds",
        "/esoui/art/compass/compass_ava_imperialcity_aldmeri.dds",
        "/esoui/art/compass/compass_ava_imperialcity_daggerfall.dds",
        "/esoui/art/compass/compass_ava_imperialcity_ebonheart.dds",
        "/esoui/art/compass/compass_ava_imperialcity_neutral.dds",
        "/esoui/art/compass/compass_waypoint.dds",
        "/esoui/art/compass/groupleader.dds",
        "/esoui/art/compass/groupleader_door.dds",
        "/esoui/art/compass/quest_areapin.dds",
        "/esoui/art/compass/quest_assistedareapin.dds",
        "/esoui/art/compass/quest_available_icon.dds",
        "/esoui/art/compass/quest_icon.dds",
        "/esoui/art/compass/quest_icon_assisted.dds",
        "/esoui/art/compass/quest_icon_door.dds",
        "/esoui/art/compass/quest_icon_door_assisted.dds",
        "/esoui/art/contacts/social_allianceicon_aldmeri.dds",
        "/esoui/art/contacts/social_allianceicon_daggerfall.dds",
        "/esoui/art/contacts/social_allianceicon_ebonheart.dds",
        "/esoui/art/contacts/social_classicon_dragonknight.dds",
        "/esoui/art/contacts/social_classicon_nightblade.dds",
        "/esoui/art/contacts/social_classicon_sorcerer.dds",
        "/esoui/art/contacts/social_classicon_templar.dds",
        "/esoui/art/contacts/social_list_bgstrip.dds",
        "/esoui/art/contacts/social_list_bgstrip_highlight.dds",
        "/esoui/art/contacts/social_note_down.dds",
        "/esoui/art/contacts/social_note_over.dds",
        "/esoui/art/contacts/social_note_up.dds",
        "/esoui/art/contacts/social_status_afk.dds",
        "/esoui/art/contacts/social_status_dnd.dds",
        "/esoui/art/contacts/social_status_highlight.dds",
        "/esoui/art/contacts/social_status_offline.dds",
        "/esoui/art/contacts/social_status_online.dds",
        "/esoui/art/contacts/tabicon_friends_down.dds",
        "/esoui/art/contacts/tabicon_friends_over.dds",
        "/esoui/art/contacts/tabicon_friends_up.dds",
        "/esoui/art/contacts/tabicon_ignored_down.dds",
        "/esoui/art/contacts/tabicon_ignored_over.dds",
        "/esoui/art/contacts/tabicon_ignored_up.dds",
        "/esoui/art/crafting/alchemy_emptyslot_reagent.dds",
        "/esoui/art/crafting/alchemy_emptyslot_solvent.dds",
        "/esoui/art/crafting/alchemy_tabicon_reagent_disabled.dds",
        "/esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
        "/esoui/art/crafting/alchemy_tabicon_reagent_over.dds",
        "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
        "/esoui/art/crafting/alchemy_tabicon_solvent_disabled.dds",
        "/esoui/art/crafting/alchemy_tabicon_solvent_down.dds",
        "/esoui/art/crafting/alchemy_tabicon_solvent_over.dds",
        "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
        "/esoui/art/crafting/arrow.dds",
        "/esoui/art/crafting/blackcircle.dds",
        "/esoui/art/crafting/burst_blue.dds",
        "/esoui/art/crafting/burst_red.dds",
        "/esoui/art/crafting/crafting_alchemy_badslot.dds",
        "/esoui/art/crafting/crafting_alchemy_goodslot.dds",
        "/esoui/art/crafting/crafting_alchemy_slottingbg.dds",
        "/esoui/art/crafting/crafting_alchemy_trait_slot.dds",
        "/esoui/art/crafting/crafting_enchanting_extraction_landingarea_overlay.dds",
        "/esoui/art/crafting/crafting_enchanting_glyphslot_pentagon.dds",
        "/esoui/art/crafting/crafting_enchanting_glyphslot_round.dds",
        "/esoui/art/crafting/crafting_enchanting_glyphslot_shield.dds",
        "/esoui/art/crafting/crafting_enchanting_slottingbg.dds",
        "/esoui/art/crafting/crafting_provisioner_inventorycolumn_icon.dds",
        "/esoui/art/crafting/crafting_runestone01_drag.dds",
        "/esoui/art/crafting/crafting_runestone01_negative.dds",
        "/esoui/art/crafting/crafting_runestone01_slot.dds",
        "/esoui/art/crafting/crafting_runestone02_drag.dds",
        "/esoui/art/crafting/crafting_runestone02_negative.dds",
        "/esoui/art/crafting/crafting_runestone02_slot.dds",
        "/esoui/art/crafting/crafting_runestone03_drag.dds",
        "/esoui/art/crafting/crafting_runestone03_negative.dds",
        "/esoui/art/crafting/crafting_runestone03_slot.dds",
        "/esoui/art/crafting/crafting_smithing_notrait.dds",
        "/esoui/art/crafting/crafting_tooltip_glow_center.dds",
        "/esoui/art/crafting/crafting_tooltip_glow_edge.dds",
        "/esoui/art/crafting/crafting_tooltip_glow_edge_blue64.dds",
        "/esoui/art/crafting/crafting_tooltip_glow_edge_red64.dds",
        "/esoui/art/crafting/enchantment_tabicon_aspect_disabled.dds",
        "/esoui/art/crafting/enchantment_tabicon_aspect_down.dds",
        "/esoui/art/crafting/enchantment_tabicon_aspect_over.dds",
        "/esoui/art/crafting/enchantment_tabicon_aspect_up.dds",
        "/esoui/art/crafting/enchantment_tabicon_deconstruction_disabled.dds",
        "/esoui/art/crafting/enchantment_tabicon_deconstruction_down.dds",
        "/esoui/art/crafting/enchantment_tabicon_deconstruction_over.dds",
        "/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
        "/esoui/art/crafting/enchantment_tabicon_essence_disabled.dds",
        "/esoui/art/crafting/enchantment_tabicon_essence_down.dds",
        "/esoui/art/crafting/enchantment_tabicon_essence_over.dds",
        "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
        "/esoui/art/crafting/enchantment_tabicon_potency_disabled.dds",
        "/esoui/art/crafting/enchantment_tabicon_potency_down.dds",
        "/esoui/art/crafting/enchantment_tabicon_potency_over.dds",
        "/esoui/art/crafting/enchantment_tabicon_potency_up.dds",
        "/esoui/art/crafting/inspirationbar_glow.dds",
        "/esoui/art/crafting/provisioner_indexicon_beer_disabled.dds",
        "/esoui/art/crafting/provisioner_indexicon_beer_down.dds",
        "/esoui/art/crafting/provisioner_indexicon_beer_over.dds",
        "/esoui/art/crafting/provisioner_indexicon_beer_up.dds",
        "/esoui/art/crafting/provisioner_indexicon_meat_disabled.dds",
        "/esoui/art/crafting/provisioner_indexicon_meat_down.dds",
        "/esoui/art/crafting/provisioner_indexicon_meat_over.dds",
        "/esoui/art/crafting/provisioner_indexicon_meat_up.dds",
        "/esoui/art/crafting/slot_locked_burst.dds",
        "/esoui/art/crafting/smithing_armorslot.dds",
        "/esoui/art/crafting/smithing_leftarrow_disabled.dds",
        "/esoui/art/crafting/smithing_leftarrow_down.dds",
        "/esoui/art/crafting/smithing_leftarrow_over.dds",
        "/esoui/art/crafting/smithing_leftarrow_up.dds",
        "/esoui/art/crafting/smithing_refine_emptyslot.dds",
        "/esoui/art/crafting/smithing_rightarrow_disabled.dds",
        "/esoui/art/crafting/smithing_rightarrow_down.dds",
        "/esoui/art/crafting/smithing_rightarrow_over.dds",
        "/esoui/art/crafting/smithing_rightarrow_up.dds",
        "/esoui/art/crafting/smithing_tabicon_armorset_down.dds",
        "/esoui/art/crafting/smithing_tabicon_armorset_over.dds",
        "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
        "/esoui/art/crafting/smithing_tabicon_creation_disabled.dds",
        "/esoui/art/crafting/smithing_tabicon_creation_down.dds",
        "/esoui/art/crafting/smithing_tabicon_creation_over.dds",
        "/esoui/art/crafting/smithing_tabicon_creation_up.dds",
        "/esoui/art/crafting/smithing_tabicon_improve_disabled.dds",
        "/esoui/art/crafting/smithing_tabicon_improve_down.dds",
        "/esoui/art/crafting/smithing_tabicon_improve_over.dds",
        "/esoui/art/crafting/smithing_tabicon_improve_up.dds",
        "/esoui/art/crafting/smithing_tabicon_refine_disabled.dds",
        "/esoui/art/crafting/smithing_tabicon_refine_down.dds",
        "/esoui/art/crafting/smithing_tabicon_refine_over.dds",
        "/esoui/art/crafting/smithing_tabicon_refine_up.dds",
        "/esoui/art/crafting/smithing_tabicon_research_disabled.dds",
        "/esoui/art/crafting/smithing_tabicon_research_down.dds",
        "/esoui/art/crafting/smithing_tabicon_research_over.dds",
        "/esoui/art/crafting/smithing_tabicon_research_up.dds",
        "/esoui/art/crafting/smithing_tabicon_weaponset_down.dds",
        "/esoui/art/crafting/smithing_tabicon_weaponset_over.dds",
        "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
        "/esoui/art/crafting/smithing_temperchart_epic2legendary.dds",
        "/esoui/art/crafting/smithing_temperchart_fine2superior.dds",
        "/esoui/art/crafting/smithing_temperchart_normal2fine.dds",
        "/esoui/art/crafting/smithing_temperchart_superior2epic.dds",
        "/esoui/art/crafting/smithing_weaponslot.dds",
        "/esoui/art/crafting/white_burst.dds",
        "/esoui/art/death/death_soulreservoir_icon.dds",
        "/esoui/art/death/death_timer_base.dds",
        "/esoui/art/death/death_timer_fill.dds",
        "/esoui/art/deathrecap/deathrecap_attackbossframe.dds",
        "/esoui/art/deathrecap/deathrecap_attackframe.dds",
        "/esoui/art/deathrecap/deathrecap_bg_left.dds",
        "/esoui/art/deathrecap/deathrecap_bg_right.dds",
        "/esoui/art/deathrecap/deathrecap_divider_left.dds",
        "/esoui/art/deathrecap/deathrecap_divider_right.dds",
        "/esoui/art/deathrecap/deathrecap_killingblow_icon.dds",
        "/esoui/art/dye/dyes_tabicon_dye_down.dds",
        "/esoui/art/dye/dyes_tabicon_dye_over.dds",
        "/esoui/art/dye/dyes_tabicon_dye_up.dds",
        "/esoui/art/dye/dyes_toolicon_erase_down.dds",
        "/esoui/art/dye/dyes_toolicon_erase_over.dds",
        "/esoui/art/dye/dyes_toolicon_erase_up.dds",
        "/esoui/art/dye/dyes_toolicon_fill_down.dds",
        "/esoui/art/dye/dyes_toolicon_fill_over.dds",
        "/esoui/art/dye/dyes_toolicon_fill_up.dds",
        "/esoui/art/dye/dyes_toolicon_paint_down.dds",
        "/esoui/art/dye/dyes_toolicon_paint_over.dds",
        "/esoui/art/dye/dyes_toolicon_paint_up.dds",
        "/esoui/art/dye/dyes_toolicon_sample_down.dds",
        "/esoui/art/dye/dyes_toolicon_sample_over.dds",
        "/esoui/art/dye/dyes_toolicon_sample_up.dds",
        "/esoui/art/dye/dyes_toolicon_setfill_down.dds",
        "/esoui/art/dye/dyes_toolicon_setfill_over.dds",
        "/esoui/art/dye/dyes_toolicon_setfill_up.dds",
        "/esoui/art/dye/dye_amorslot.dds",
        "/esoui/art/dye/dye_amorslot_empty.dds",
        "/esoui/art/dye/dye_amorslot_highlight.dds",
        "/esoui/art/dye/dye_swatch_highlight.dds",
        "/esoui/art/dye/swatch_multitexture.dds",
        "/esoui/art/enchanting/enchanting_highlight.dds",
        "/esoui/art/fishing/bait_emptyslot.dds",
        "/esoui/art/floatingmarkers/quest_available_icon.dds",
        "/esoui/art/floatingmarkers/quest_icon.dds",
        "/esoui/art/floatingmarkers/quest_icon_assisted.dds",
        "/esoui/art/floatingmarkers/quest_icon_door.dds",
        "/esoui/art/floatingmarkers/quest_icon_door_assisted.dds",
        "/esoui/art/friends/friends_tabicon_friends_inactive.dds",
        "/esoui/art/friends/friends_tabicon_ignore_inactive.dds",
        "/esoui/art/gammaadjust/gamma_referenceimage1.dds",
        "/esoui/art/gammaadjust/gamma_referenceimage2.dds",
        "/esoui/art/gammaadjust/gamma_referenceimage3.dds",
        "/esoui/art/guild/banner_aldmeri.dds",
        "/esoui/art/guild/banner_daggerfall.dds",
        "/esoui/art/guild/banner_ebonheart.dds",
        "/esoui/art/guild/guildbanner_icon_aldmeri.dds",
        "/esoui/art/guild/guildbanner_icon_daggerfall.dds",
        "/esoui/art/guild/guildbanner_icon_ebonheart.dds",
        "/esoui/art/guild/guildheraldry_indexicon_background_disabled.dds",
        "/esoui/art/guild/guildheraldry_indexicon_background_down.dds",
        "/esoui/art/guild/guildheraldry_indexicon_background_over.dds",
        "/esoui/art/guild/guildheraldry_indexicon_background_up.dds",
        "/esoui/art/guild/guildheraldry_indexicon_crest_disabled.dds",
        "/esoui/art/guild/guildheraldry_indexicon_crest_down.dds",
        "/esoui/art/guild/guildheraldry_indexicon_crest_over.dds",
        "/esoui/art/guild/guildheraldry_indexicon_crest_up.dds",
        "/esoui/art/guild/guildheraldry_indexicon_finalize_disabled.dds",
        "/esoui/art/guild/guildheraldry_indexicon_finalize_down.dds",
        "/esoui/art/guild/guildheraldry_indexicon_finalize_over.dds",
        "/esoui/art/guild/guildheraldry_indexicon_finalize_up.dds",
        "/esoui/art/guild/guildheraldry_swatchframe_multitexture.dds",
        "/esoui/art/guild/guildheraldry_swatchframe_overselect.dds",
        "/esoui/art/guild/guildhistory_indexicon_alliancewar_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_alliancewar_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_alliancewar_up.dds",
        "/esoui/art/guild/guildhistory_indexicon_campaigns_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_campaigns_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_campaigns_up.dds",
        "/esoui/art/guild/guildhistory_indexicon_combat_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_combat_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_combat_up.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildbank_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildbank_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildbank_up.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildstore_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildstore_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds",
        "/esoui/art/guild/guildhistory_indexicon_guild_down.dds",
        "/esoui/art/guild/guildhistory_indexicon_guild_over.dds",
        "/esoui/art/guild/guildhistory_indexicon_guild_up.dds",
        "/esoui/art/guild/guildranks_iconframe_normal.dds",
        "/esoui/art/guild/guildranks_iconframe_selected.dds",
        "/esoui/art/guild/guild_bankaccess.dds",
        "/esoui/art/guild/guild_heraldryaccess.dds",
        "/esoui/art/guild/guild_indexicon_recruit_down.dds",
        "/esoui/art/guild/guild_indexicon_recruit_over.dds",
        "/esoui/art/guild/guild_indexicon_recruit_up.dds",
        "/esoui/art/guild/guild_rankicon_recruit.dds",
        "/esoui/art/guild/guild_rankicon_recruit_large.dds",
        "/esoui/art/guild/guild_tradinghouseaccess.dds",
        "/esoui/art/guild/ownership_icon_farm.dds",
        "/esoui/art/guild/ownership_icon_guildtrader.dds",
        "/esoui/art/guild/ownership_icon_keep.dds",
        "/esoui/art/guild/ownership_icon_lumbermill.dds",
        "/esoui/art/guild/ownership_icon_mine.dds",
        "/esoui/art/guild/sectiondivider_left.dds",
        "/esoui/art/guild/sectiondivider_right.dds",
        "/esoui/art/guild/tabicon_heraldry_disabled.dds",
        "/esoui/art/guild/tabicon_heraldry_down.dds",
        "/esoui/art/guild/tabicon_heraldry_over.dds",
        "/esoui/art/guild/tabicon_heraldry_up.dds",
        "/esoui/art/guild/tabicon_history_disabled.dds",
        "/esoui/art/guild/tabicon_history_down.dds",
        "/esoui/art/guild/tabicon_history_over.dds",
        "/esoui/art/guild/tabicon_history_up.dds",
        "/esoui/art/guild/tabicon_home_disabled.dds",
        "/esoui/art/guild/tabicon_home_down.dds",
        "/esoui/art/guild/tabicon_home_over.dds",
        "/esoui/art/guild/tabicon_home_up.dds",
        "/esoui/art/guild/tabicon_ranks_disabled.dds",
        "/esoui/art/guild/tabicon_ranks_down.dds",
        "/esoui/art/guild/tabicon_ranks_over.dds",
        "/esoui/art/guild/tabicon_ranks_up.dds",
        "/esoui/art/guild/tabicon_roster_disabled.dds",
        "/esoui/art/guild/tabicon_roster_down.dds",
        "/esoui/art/guild/tabicon_roster_over.dds",
        "/esoui/art/guild/tabicon_roster_up.dds",
        "/esoui/art/help/help_tabicon_cs_disabled.dds",
        "/esoui/art/help/help_tabicon_cs_down.dds",
        "/esoui/art/help/help_tabicon_cs_over.dds",
        "/esoui/art/help/help_tabicon_cs_up.dds",
        "/esoui/art/help/help_tabicon_tutorial_disabled.dds",
        "/esoui/art/help/help_tabicon_tutorial_down.dds",
        "/esoui/art/help/help_tabicon_tutorial_over.dds",
        "/esoui/art/help/help_tabicon_tutorial_up.dds",
        "/esoui/art/housing/keyboard/furniture_tabicon_crownfurnishings_up.dds",
        "/esoui/art/hud/chargebar_frame.dds",
        "/esoui/art/hud/cloud.dds",
        "/esoui/art/hud/radialicon_addfriend_disabled.dds",
        "/esoui/art/hud/radialicon_addfriend_over.dds",
        "/esoui/art/hud/radialicon_addfriend_up.dds",
        "/esoui/art/hud/radialicon_cancel_disabled.dds",
        "/esoui/art/hud/radialicon_cancel_over.dds",
        "/esoui/art/hud/radialicon_cancel_up.dds",
        "/esoui/art/hud/radialicon_invitegroup_disabled.dds",
        "/esoui/art/hud/radialicon_invitegroup_over.dds",
        "/esoui/art/hud/radialicon_invitegroup_up.dds",
        "/esoui/art/hud/radialicon_removefriend_disabled.dds",
        "/esoui/art/hud/radialicon_removefriend_over.dds",
        "/esoui/art/hud/radialicon_removefriend_up.dds",
        "/esoui/art/hud/radialicon_removefromgroup_disabled.dds",
        "/esoui/art/hud/radialicon_removefromgroup_over.dds",
        "/esoui/art/hud/radialicon_removefromgroup_up.dds",
        "/esoui/art/hud/radialicon_reportplayer_disabled.dds",
        "/esoui/art/hud/radialicon_reportplayer_over.dds",
        "/esoui/art/hud/radialicon_reportplayer_up.dds",
        "/esoui/art/hud/radialicon_trade_disabled.dds",
        "/esoui/art/hud/radialicon_trade_over.dds",
        "/esoui/art/hud/radialicon_trade_up.dds",
        "/esoui/art/hud/radialicon_whisper_disabled.dds",
        "/esoui/art/hud/radialicon_whisper_over.dds",
        "/esoui/art/hud/radialicon_whisper_up.dds",
        "/esoui/art/hud/radialmenu_bg.dds",
        "/esoui/art/hud/radialmenu_bg_unselected.dds",
        "/esoui/art/hud/revivemeter_frame.dds",
        "/esoui/art/hud/revivemeter_progbar.dds",
        "/esoui/art/hud/starburst.dds",
        "/esoui/art/hud/xpbar_divider.dds",
        "/esoui/art/hud/xpbar_efxoverlay.dds",
        "/esoui/art/hud/xpbar_frame.dds",
        "/esoui/art/hud/xpbar_gridoverlay.dds",
        "/esoui/art/hud/xpbar_progbarbase.dds",
        "/esoui/art/interaction/conversation_textbg.dds",
        "/esoui/art/interaction/conversation_verticalborder.dds",
        "/esoui/art/inventory/gp_inventory_equipped_other_slot.dds",
        "/esoui/art/inventory/gp_inventory_equipped_this_slot.dds",
        "/esoui/art/inventory/inventory_all_tabicon_active.dds",
        "/esoui/art/inventory/inventory_all_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_all_tabicon_mouseover.dds",
        "/esoui/art/inventory/inventory_armor_tabicon_active.dds",
        "/esoui/art/inventory/inventory_armor_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_consumables_tabicon_active.dds",
        "/esoui/art/inventory/inventory_consumables_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_craft_tabicon_active.dds",
        "/esoui/art/inventory/inventory_craft_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_junk_tabicon_active.dds",
        "/esoui/art/inventory/inventory_junk_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_misc_tabicon_active.dds",
        "/esoui/art/inventory/inventory_misc_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_quest_tabicon_active.dds",
        "/esoui/art/inventory/inventory_quest_tabicon_inactive.dds",
        "/esoui/art/inventory/inventory_stolenitem_icon.dds",
        "/esoui/art/inventory/inventory_tabicon_all_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_all_down.dds",
        "/esoui/art/inventory/inventory_tabicon_all_over.dds",
        "/esoui/art/inventory/inventory_tabicon_all_up.dds",
        "/esoui/art/inventory/inventory_tabicon_armor_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_armor_down.dds",
        "/esoui/art/inventory/inventory_tabicon_armor_over.dds",
        "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
        "/esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_consumables_down.dds",
        "/esoui/art/inventory/inventory_tabicon_consumables_over.dds",
        "/esoui/art/inventory/inventory_tabicon_consumables_up.dds",
        "/esoui/art/inventory/inventory_tabicon_crafting_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_crafting_down.dds",
        "/esoui/art/inventory/inventory_tabicon_crafting_over.dds",
        "/esoui/art/inventory/inventory_tabicon_crafting_up.dds",
        "/esoui/art/inventory/inventory_tabicon_junk_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_junk_down.dds",
        "/esoui/art/inventory/inventory_tabicon_junk_over.dds",
        "/esoui/art/inventory/inventory_tabicon_junk_up.dds",
        "/esoui/art/inventory/inventory_tabicon_misc_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_misc_down.dds",
        "/esoui/art/inventory/inventory_tabicon_misc_over.dds",
        "/esoui/art/inventory/inventory_tabicon_misc_up.dds",
        "/esoui/art/inventory/inventory_tabicon_quest_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_quest_down.dds",
        "/esoui/art/inventory/inventory_tabicon_quest_over.dds",
        "/esoui/art/inventory/inventory_tabicon_quest_up.dds",
        "/esoui/art/inventory/inventory_tabicon_quickslot_down.dds",
        "/esoui/art/inventory/inventory_tabicon_quickslot_over.dds",
        "/esoui/art/inventory/inventory_tabicon_quickslot_up.dds",
        "/esoui/art/inventory/inventory_tabicon_weapons_disabled.dds",
        "/esoui/art/inventory/inventory_tabicon_weapons_down.dds",
        "/esoui/art/inventory/inventory_tabicon_weapons_over.dds",
        "/esoui/art/inventory/inventory_tabicon_weapons_up.dds",
        "/esoui/art/inventory/inventory_weapons_tabicon_active.dds",
        "/esoui/art/inventory/inventory_weapons_tabicon_inactive.dds",
        "/esoui/art/inventory/newitem_icon.dds",
        "/esoui/art/itemtooltip/iconstrip.dds",
        "/esoui/art/itemtooltip/item_chargemeter.dds",
        "/esoui/art/itemtooltip/item_chargemeter_bar_genericfill.dds",
        "/esoui/art/itemtooltip/item_chargemeter_bar_genericfill_gloss.dds",
        "/esoui/art/itemtooltip/item_chargemeter_bar_leadingedge.dds",
        "/esoui/art/itemtooltip/item_chargemeter_bar_leadingedge_gloss.dds",
        "/esoui/art/itemtooltip/simpleprogbarbg_center.dds",
        "/esoui/art/itemtooltip/simpleprogbarbg_edge.dds",
        "/esoui/art/journal/journal_tabicon_achievements_disabled.dds",
        "/esoui/art/journal/journal_tabicon_achievements_down.dds",
        "/esoui/art/journal/journal_tabicon_achievements_over.dds",
        "/esoui/art/journal/journal_tabicon_achievements_up.dds",
        "/esoui/art/journal/journal_tabicon_cadwell_disabled.dds",
        "/esoui/art/journal/journal_tabicon_cadwell_down.dds",
        "/esoui/art/journal/journal_tabicon_cadwell_over.dds",
        "/esoui/art/journal/journal_tabicon_cadwell_up.dds",
        "/esoui/art/journal/journal_tabicon_leaderboard_disabled.dds",
        "/esoui/art/journal/journal_tabicon_leaderboard_down.dds",
        "/esoui/art/journal/journal_tabicon_leaderboard_over.dds",
        "/esoui/art/journal/journal_tabicon_leaderboard_up.dds",
        "/esoui/art/journal/journal_tabicon_lorelibrary_disabled.dds",
        "/esoui/art/journal/journal_tabicon_lorelibrary_down.dds",
        "/esoui/art/journal/journal_tabicon_lorelibrary_over.dds",
        "/esoui/art/journal/journal_tabicon_lorelibrary_up.dds",
        "/esoui/art/journal/journal_tabicon_quest_disabled.dds",
        "/esoui/art/journal/journal_tabicon_quest_down.dds",
        "/esoui/art/journal/journal_tabicon_quest_over.dds",
        "/esoui/art/journal/journal_tabicon_quest_up.dds",
        "/esoui/art/journal/leaderboard_indexicon_ava_disabled.dds",
        "/esoui/art/journal/leaderboard_indexicon_ava_down.dds",
        "/esoui/art/journal/leaderboard_indexicon_ava_over.dds",
        "/esoui/art/journal/leaderboard_indexicon_ava_up.dds",
        "/esoui/art/journal/leaderboard_indexicon_challenge_disabled.dds",
        "/esoui/art/journal/leaderboard_indexicon_challenge_down.dds",
        "/esoui/art/journal/leaderboard_indexicon_challenge_over.dds",
        "/esoui/art/journal/leaderboard_indexicon_challenge_up.dds",
        "/esoui/art/journal/leaderboard_indexicon_raids_disabled.dds",
        "/esoui/art/journal/leaderboard_indexicon_raids_down.dds",
        "/esoui/art/journal/leaderboard_indexicon_raids_over.dds",
        "/esoui/art/journal/leaderboard_indexicon_raids_up.dds",
        "/esoui/art/journal/leaderboard_tabicon_guest_disabled.dds",
        "/esoui/art/journal/leaderboard_tabicon_guest_down.dds",
        "/esoui/art/journal/leaderboard_tabicon_guest_over.dds",
        "/esoui/art/journal/leaderboard_tabicon_guest_up.dds",
        "/esoui/art/journal/leaderboard_tabicon_home_disabled.dds",
        "/esoui/art/journal/leaderboard_tabicon_home_down.dds",
        "/esoui/art/journal/leaderboard_tabicon_home_over.dds",
        "/esoui/art/journal/leaderboard_tabicon_home_up.dds",
        "/esoui/art/lfg/lfg_dps_down.dds",
        "/esoui/art/lfg/lfg_dps_over.dds",
        "/esoui/art/lfg/lfg_dps_up.dds",
        "/esoui/art/lfg/lfg_healer_down.dds",
        "/esoui/art/lfg/lfg_healer_over.dds",
        "/esoui/art/lfg/lfg_healer_up.dds",
        "/esoui/art/lfg/lfg_leader_icon.dds",
        "/esoui/art/lfg/lfg_normaldungeon_disabled.dds",
        "/esoui/art/lfg/lfg_normaldungeon_down.dds",
        "/esoui/art/lfg/lfg_normaldungeon_down_disabled.dds",
        "/esoui/art/lfg/lfg_normaldungeon_over.dds",
        "/esoui/art/lfg/lfg_normaldungeon_up.dds",
        "/esoui/art/lfg/lfg_tabicon_grouptools_disabled.dds",
        "/esoui/art/lfg/lfg_tabicon_grouptools_down.dds",
        "/esoui/art/lfg/lfg_tabicon_grouptools_over.dds",
        "/esoui/art/lfg/lfg_tabicon_grouptools_up.dds",
        "/esoui/art/lfg/lfg_tabicon_mygroup_disabled.dds",
        "/esoui/art/lfg/lfg_tabicon_mygroup_down.dds",
        "/esoui/art/lfg/lfg_tabicon_mygroup_over.dds",
        "/esoui/art/lfg/lfg_tabicon_mygroup_up.dds",
        "/esoui/art/lfg/lfg_tank_down.dds",
        "/esoui/art/lfg/lfg_tank_over.dds",
        "/esoui/art/lfg/lfg_tank_up.dds",
        "/esoui/art/lfg/lfg_veterandungeon_disabled.dds",
        "/esoui/art/lfg/lfg_veterandungeon_down.dds",
        "/esoui/art/lfg/lfg_veterandungeon_down_disabled.dds",
        "/esoui/art/lfg/lfg_veterandungeon_over.dds",
        "/esoui/art/lfg/lfg_veterandungeon_up.dds",
        "/esoui/art/lockpicking/lock_body.dds",
        "/esoui/art/lockpicking/lock_mask.dds",
        "/esoui/art/lockpicking/lock_pick.dds",
        "/esoui/art/lockpicking/lock_pick_broken_left.dds",
        "/esoui/art/lockpicking/lock_pick_broken_right.dds",
        "/esoui/art/lockpicking/lock_tensioner_bottom.dds",
        "/esoui/art/lockpicking/lock_tensioner_top.dds",
        "/esoui/art/lockpicking/pins.dds",
        "/esoui/art/lockpicking/pins_over.dds",
        "/esoui/art/lockpicking/pins_set.dds",
        "/esoui/art/lockpicking/spring_01.dds",
        "/esoui/art/lockpicking/spring_02.dds",
        "/esoui/art/lockpicking/spring_03.dds",
        "/esoui/art/lockpicking/spring_04.dds",
        "/esoui/art/lockpicking/spring_05.dds",
        "/esoui/art/login/authentication_public_down.dds",
        "/esoui/art/login/authentication_public_over.dds",
        "/esoui/art/login/authentication_public_up.dds",
        "/esoui/art/login/authentication_trusted_down.dds",
        "/esoui/art/login/authentication_trusted_over.dds",
        "/esoui/art/login/authentication_trusted_up.dds",
        "/esoui/art/login/bethesda_logo.dds",
        "/esoui/art/login/credits_bethesda_logo.dds",
        "/esoui/art/login/credits_bink.dds",
        "/esoui/art/login/credits_eso_bw.dds",
        "/esoui/art/login/credits_eso_bw_logotype.dds",
        "/esoui/art/login/credits_forkparticlelogo.dds",
        "/esoui/art/login/credits_granny.dds",
        "/esoui/art/login/credits_ourosboros.dds",
        "/esoui/art/login/credits_zenimax_media_logo.dds",
        "/esoui/art/login/credits_zos_logo.dds",
        "/esoui/art/login/esrb_warning.dds",
        "/esoui/art/login/havok_logo.dds",
        "/esoui/art/login/loginbg_ourosboros.dds",
        "/esoui/art/login/login_divider.dds",
        "/esoui/art/login/login_framingbar.dds",
        "/esoui/art/login/login_logo_left.dds",
        "/esoui/art/login/login_logo_right.dds",
        "/esoui/art/login/login_uiwindowbg_left.dds",
        "/esoui/art/login/login_uiwindowbg_right.dds",
        "/esoui/art/login/zenimax_media_logo.dds",
        "/esoui/art/login/zos_logo.dds",
        "/esoui/art/loot/loot_finesseitem.dds",
        "/esoui/art/loot/loot_topdivider.dds",
        "/esoui/art/loot/loot_windowbg.dds",
        "/esoui/art/lorelibrary/lorelibrary_bg_left.dds",
        "/esoui/art/lorelibrary/lorelibrary_bg_right.dds",
        "/esoui/art/lorelibrary/lorelibrary_letter.dds",
        "/esoui/art/lorelibrary/lorelibrary_note.dds",
        "/esoui/art/lorelibrary/lorelibrary_paperbook.dds",
        "/esoui/art/lorelibrary/lorelibrary_rubbingbook.dds",
        "/esoui/art/lorelibrary/lorelibrary_scroll.dds",
        "/esoui/art/lorelibrary/lorelibrary_skinbook.dds",
        "/esoui/art/lorelibrary/lorelibrary_stonetablet.dds",
        "/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds",
        "/esoui/art/mail/mail_attachment_empty.dds",
        "/esoui/art/mail/mail_csicon.dds",
        "/esoui/art/mail/mail_divider.dds",
        "/esoui/art/mail/mail_inbox_messagebg_left.dds",
        "/esoui/art/mail/mail_inbox_messagebg_right.dds",
        "/esoui/art/mail/mail_inbox_readmessage.dds",
        "/esoui/art/mail/mail_inbox_returned.dds",
        "/esoui/art/mail/mail_inbox_unreadmessage.dds",
        "/esoui/art/mail/mail_systemicon.dds",
        "/esoui/art/mail/mail_tabicon_compose_down.dds",
        "/esoui/art/mail/mail_tabicon_compose_over.dds",
        "/esoui/art/mail/mail_tabicon_compose_up.dds",
        "/esoui/art/mail/mail_tabicon_inbox_down.dds",
        "/esoui/art/mail/mail_tabicon_inbox_over.dds",
        "/esoui/art/mail/mail_tabicon_inbox_up.dds",
        "/esoui/art/mainmenu/menubar_ava_disabled.dds",
        "/esoui/art/mainmenu/menubar_ava_down.dds",
        "/esoui/art/mainmenu/menubar_ava_over.dds",
        "/esoui/art/mainmenu/menubar_ava_up.dds",
        "/esoui/art/mainmenu/menubar_character_disabled.dds",
        "/esoui/art/mainmenu/menubar_character_down.dds",
        "/esoui/art/mainmenu/menubar_character_over.dds",
        "/esoui/art/mainmenu/menubar_character_up.dds",
        "/esoui/art/mainmenu/menubar_group_disabled.dds",
        "/esoui/art/mainmenu/menubar_group_down.dds",
        "/esoui/art/mainmenu/menubar_group_over.dds",
        "/esoui/art/mainmenu/menubar_group_up.dds",
        "/esoui/art/mainmenu/menubar_guilds_disabled.dds",
        "/esoui/art/mainmenu/menubar_guilds_down.dds",
        "/esoui/art/mainmenu/menubar_guilds_over.dds",
        "/esoui/art/mainmenu/menubar_guilds_up.dds",
        "/esoui/art/mainmenu/menubar_inventory_disabled.dds",
        "/esoui/art/mainmenu/menubar_inventory_down.dds",
        "/esoui/art/mainmenu/menubar_inventory_over.dds",
        "/esoui/art/mainmenu/menubar_inventory_up.dds",
        "/esoui/art/mainmenu/menubar_journal_disabled.dds",
        "/esoui/art/mainmenu/menubar_journal_down.dds",
        "/esoui/art/mainmenu/menubar_journal_over.dds",
        "/esoui/art/mainmenu/menubar_journal_up.dds",
        "/esoui/art/mainmenu/menubar_mail_disabled.dds",
        "/esoui/art/mainmenu/menubar_mail_down.dds",
        "/esoui/art/mainmenu/menubar_mail_over.dds",
        "/esoui/art/mainmenu/menubar_mail_up.dds",
        "/esoui/art/mainmenu/menubar_map_disabled.dds",
        "/esoui/art/mainmenu/menubar_map_down.dds",
        "/esoui/art/mainmenu/menubar_map_over.dds",
        "/esoui/art/mainmenu/menubar_map_up.dds",
        "/esoui/art/mainmenu/menubar_notifications_disabled.dds",
        "/esoui/art/mainmenu/menubar_notifications_down.dds",
        "/esoui/art/mainmenu/menubar_notifications_over.dds",
        "/esoui/art/mainmenu/menubar_notifications_up.dds",
        "/esoui/art/mainmenu/menubar_skills_disabled.dds",
        "/esoui/art/mainmenu/menubar_skills_down.dds",
        "/esoui/art/mainmenu/menubar_skills_over.dds",
        "/esoui/art/mainmenu/menubar_skills_up.dds",
        "/esoui/art/mainmenu/menubar_social_disabled.dds",
        "/esoui/art/mainmenu/menubar_social_down.dds",
        "/esoui/art/mainmenu/menubar_social_over.dds",
        "/esoui/art/mainmenu/menubar_social_up.dds",
        "/esoui/art/mainmenu/menubar_voip_disabled.dds",
        "/esoui/art/mainmenu/menubar_voip_down.dds",
        "/esoui/art/mainmenu/menubar_voip_over.dds",
        "/esoui/art/mainmenu/menubar_voip_up.dds",
        "/esoui/art/mappins/ava_3way.dds",
        "/esoui/art/mappins/ava_artifactgate_aldmeri_closed.dds",
        "/esoui/art/mappins/ava_artifactgate_aldmeri_open.dds",
        "/esoui/art/mappins/ava_artifactgate_daggerfall_closed.dds",
        "/esoui/art/mappins/ava_artifactgate_daggerfall_open.dds",
        "/esoui/art/mappins/ava_artifactgate_ebonheart_closed.dds",
        "/esoui/art/mappins/ava_artifactgate_ebonheart_open.dds",
        "/esoui/art/mappins/ava_artifacttemple_aldmeri.dds",
        "/esoui/art/mappins/ava_artifacttemple_aldmeril_underattack.dds",
        "/esoui/art/mappins/ava_artifacttemple_daggerfall.dds",
        "/esoui/art/mappins/ava_artifacttemple_daggerfall_underattack.dds",
        "/esoui/art/mappins/ava_artifacttemple_ebonheart.dds",
        "/esoui/art/mappins/ava_artifacttemple_ebonheart_underattack.dds",
        "/esoui/art/mappins/ava_artifact_almaruma.dds",
        "/esoui/art/mappins/ava_artifact_altadoon.dds",
        "/esoui/art/mappins/ava_artifact_chim.dds",
        "/esoui/art/mappins/ava_artifact_ghartok.dds",
        "/esoui/art/mappins/ava_artifact_mnem.dds",
        "/esoui/art/mappins/ava_artifact_nimohk.dds",
        "/esoui/art/mappins/ava_attackburst_32.dds",
        "/esoui/art/mappins/ava_attackburst_64.dds",
        "/esoui/art/mappins/ava_borderkeep_linked_backdrop.dds",
        "/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds",
        "/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds",
        "/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds",
        "/esoui/art/mappins/ava_cemetary_aldmeri.dds",
        "/esoui/art/mappins/ava_cemetary_daggerfall.dds",
        "/esoui/art/mappins/ava_cemetary_ebonheart.dds",
        "/esoui/art/mappins/ava_cemetary_linked_backdrop.dds",
        "/esoui/art/mappins/ava_keeptransitselection.dds",
        "/esoui/art/mappins/ava_keep_linked_backdrop.dds",
        "/esoui/art/mappins/ava_largekeep_aldmeri.dds",
        "/esoui/art/mappins/ava_largekeep_aldmeri_underattack.dds",
        "/esoui/art/mappins/ava_largekeep_daggerfall.dds",
        "/esoui/art/mappins/ava_largekeep_daggerfall_underattack.dds",
        "/esoui/art/mappins/ava_largekeep_ebonheart.dds",
        "/esoui/art/mappins/ava_largekeep_ebonheart_underattack.dds",
        "/esoui/art/mappins/ava_largekeep_neutral.dds",
        "/esoui/art/mappins/ava_largekeep_neutral_underattack.dds",
        "/esoui/art/mappins/ava_outpost_aldmeri.dds",
        "/esoui/art/mappins/ava_outpost_daggerfall.dds",
        "/esoui/art/mappins/ava_outpost_ebonheart.dds",
        "/esoui/art/mappins/ava_outpost_linked_backdrop.dds",
        "/esoui/art/mappins/ava_outpost_neutral.dds",
        "/esoui/art/mappins/ava_transitlink_aldmeri.dds",
        "/esoui/art/mappins/ava_transitlink_daggerfall.dds",
        "/esoui/art/mappins/ava_transitlink_ebonheart.dds",
        "/esoui/art/mappins/compassvendor.dds",
        "/esoui/art/mappins/follower_pin.dds",
        "/esoui/art/mappins/group_pin.dds",
        "/esoui/art/mappins/hostile_pin.dds",
        "/esoui/art/mappins/mapping.dds",
        "/esoui/art/mappins/mappingarrow.dds",
        "/esoui/art/mappins/maprallypoint.dds",
        "/esoui/art/mappins/maprallypointarrow.dds",
        "/esoui/art/mappins/map_areapin.dds",
        "/esoui/art/mappins/map_areapin_32.dds",
        "/esoui/art/mappins/map_assistedareapin.dds",
        "/esoui/art/mappins/map_assistedareapin_32.dds",
        "/esoui/art/mappins/minimap_bank.dds",
        "/esoui/art/mappins/poi_wayshrine_glow.dds",
        "/esoui/art/mappins/travel_aldmerilwayshrine.dds",
        "/esoui/art/mappins/travel_daggerfallwayshrine.dds",
        "/esoui/art/mappins/travel_ebonheartfallwayshrine.dds",
        "/esoui/art/mappins/ui-worldmapplayercamerapip.dds",
        "/esoui/art/mappins/ui_worldmap_pin_customdestination.dds",
        "/esoui/art/mappins/wayshrine.dds",
        "/esoui/art/mappins/wayshrine_undiscovered.dds",
        "/esoui/art/menubar/button_flash.dds",
        "/esoui/art/menubar/icon_highlight.dds",
        "/esoui/art/menubar/menubar_character_down.dds",
        "/esoui/art/menubar/menubar_character_over.dds",
        "/esoui/art/menubar/menubar_character_up.dds",
        "/esoui/art/menubar/menubar_help_disabled.dds",
        "/esoui/art/menubar/menubar_help_down.dds",
        "/esoui/art/menubar/menubar_help_over.dds",
        "/esoui/art/menubar/menubar_help_up.dds",
        "/esoui/art/menubar/menubar_inventory_down.dds",
        "/esoui/art/menubar/menubar_inventory_over.dds",
        "/esoui/art/menubar/menubar_inventory_up.dds",
        "/esoui/art/menubar/menubar_levelup_announce_down.dds",
        "/esoui/art/menubar/menubar_levelup_announce_over.dds",
        "/esoui/art/menubar/menubar_levelup_announce_up.dds",
        "/esoui/art/menubar/menubar_levelup_down.dds",
        "/esoui/art/menubar/menubar_levelup_over.dds",
        "/esoui/art/menubar/menubar_levelup_up.dds",
        "/esoui/art/menubar/menubar_mail_announce_down.dds",
        "/esoui/art/menubar/menubar_mail_announce_over.dds",
        "/esoui/art/menubar/menubar_mail_announce_up.dds",
        "/esoui/art/menubar/menubar_mail_down.dds",
        "/esoui/art/menubar/menubar_mail_over.dds",
        "/esoui/art/menubar/menubar_mail_up.dds",
        "/esoui/art/menubar/menubar_mainmenu_down.dds",
        "/esoui/art/menubar/menubar_mainmenu_over.dds",
        "/esoui/art/menubar/menubar_mainmenu_up.dds",
        "/esoui/art/menubar/menubar_quests_down.dds",
        "/esoui/art/menubar/menubar_quests_over.dds",
        "/esoui/art/menubar/menubar_quests_up.dds",
        "/esoui/art/menubar/menubar_social_down.dds",
        "/esoui/art/menubar/menubar_social_over.dds",
        "/esoui/art/menubar/menubar_social_up.dds",
        "/esoui/art/menubar/menubar_temp_down.dds",
        "/esoui/art/menubar/menubar_temp_over.dds",
        "/esoui/art/menubar/menubar_temp_up.dds",
        "/esoui/art/minimap/assisted_map_pin_above.dds",
        "/esoui/art/minimap/assisted_map_pin_below.dds",
        "/esoui/art/minimap/minimap_bracket.dds",
        "/esoui/art/minimap/minimap_filter_disabled.dds",
        "/esoui/art/minimap/minimap_frame_bottomleft.dds",
        "/esoui/art/minimap/minimap_frame_bottomright.dds",
        "/esoui/art/minimap/minimap_frame_topleft.dds",
        "/esoui/art/minimap/minimap_frame_topright.dds",
        "/esoui/art/minimap/minimap_lfg_disabled.dds",
        "/esoui/art/minimap/minimap_lfg_down.dds",
        "/esoui/art/minimap/minimap_lfg_up.dds",
        "/esoui/art/minimap/minimap_maximize_down.dds",
        "/esoui/art/minimap/minimap_maximize_up.dds",
        "/esoui/art/minimap/minimap_minimize_down.dds",
        "/esoui/art/minimap/minimap_minimize_up.dds",
        "/esoui/art/minimap/minimap_recall_disabled.dds",
        "/esoui/art/minimap/minimap_recall_down.dds",
        "/esoui/art/minimap/minimap_recall_up.dds",
        "/esoui/art/miscellaneous/announce_icon_frame.dds",
        "/esoui/art/miscellaneous/borderedinsettransparent_edgefile.dds",
        "/esoui/art/miscellaneous/borderedinset_center.dds",
        "/esoui/art/miscellaneous/borderedinset_edgefile.dds",
        "/esoui/art/miscellaneous/bottom_bar.dds",
        "/esoui/art/miscellaneous/bullet.dds",
        "/esoui/art/miscellaneous/centerscreen_indexarea_left.dds",
        "/esoui/art/miscellaneous/centerscreen_indexarea_right.dds",
        "/esoui/art/miscellaneous/centerscreen_left.dds",
        "/esoui/art/miscellaneous/centerscreen_right.dds",
        "/esoui/art/miscellaneous/centerscreen_topdivider.dds",
        "/esoui/art/miscellaneous/colorpicker_slider_vertical.dds",
        "/esoui/art/miscellaneous/dialog_scrollinset_left.dds",
        "/esoui/art/miscellaneous/dialog_scrollinset_right.dds",
        "/esoui/art/miscellaneous/dropdown_center.dds",
        "/esoui/art/miscellaneous/dropdown_edge.dds",
        "/esoui/art/miscellaneous/help_icon.dds",
        "/esoui/art/miscellaneous/horizontaldivider.dds",
        "/esoui/art/miscellaneous/icon_cmb.dds",
        "/esoui/art/miscellaneous/icon_highlight_pulse.dds",
        "/esoui/art/miscellaneous/icon_keys.dds",
        "/esoui/art/miscellaneous/icon_lmb.dds",
        "/esoui/art/miscellaneous/icon_lmbrmb.dds",
        "/esoui/art/miscellaneous/icon_rmb.dds",
        "/esoui/art/miscellaneous/insethighlight_center.dds",
        "/esoui/art/miscellaneous/insethighlight_edge.dds",
        "/esoui/art/miscellaneous/inset_bg.dds",
        "/esoui/art/miscellaneous/inset_center.dds",
        "/esoui/art/miscellaneous/inset_edgefile.dds",
        "/esoui/art/miscellaneous/interactkeyframe_center.dds",
        "/esoui/art/miscellaneous/interactkeyframe_center_4x32_down.dds",
        "/esoui/art/miscellaneous/interactkeyframe_center_4x32_over.dds",
        "/esoui/art/miscellaneous/interactkeyframe_center_down.dds",
        "/esoui/art/miscellaneous/interactkeyframe_disabled_edge.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge_4x32.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge_4x32_down.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge_4x32_over.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge_down.dds",
        "/esoui/art/miscellaneous/interactkeyframe_edge_over.dds",
        "/esoui/art/miscellaneous/key_edgefile.dds",
        "/esoui/art/miscellaneous/listitem_backdrop.dds",
        "/esoui/art/miscellaneous/listitem_highlight.dds",
        "/esoui/art/miscellaneous/listitem_selectedhighlight.dds",
        "/esoui/art/miscellaneous/list_sortdown.dds",
        "/esoui/art/miscellaneous/list_sortheader_icon_neutral.dds",
        "/esoui/art/miscellaneous/list_sortheader_icon_over.dds",
        "/esoui/art/miscellaneous/list_sortheader_icon_sortdown.dds",
        "/esoui/art/miscellaneous/list_sortheader_icon_sortup.dds",
        "/esoui/art/miscellaneous/list_sortup.dds",
        "/esoui/art/miscellaneous/locked_down.dds",
        "/esoui/art/miscellaneous/locked_over.dds",
        "/esoui/art/miscellaneous/locked_up.dds",
        "/esoui/art/miscellaneous/medium_bg_bottom.dds",
        "/esoui/art/miscellaneous/medium_bg_top.dds",
        "/esoui/art/miscellaneous/mungewindow_512.dds",
        "/esoui/art/miscellaneous/new_icon.dds",
        "/esoui/art/miscellaneous/progressbar_frame.dds",
        "/esoui/art/miscellaneous/progressbar_frame_bg.dds",
        "/esoui/art/miscellaneous/progressbar_genericfill_gloss.dds",
        "/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_blunt.dds",
        "/esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds",
        "/esoui/art/miscellaneous/progressbar_genericfill_tall.dds",
        "/esoui/art/miscellaneous/progressbar_texture_overlay.dds",
        "/esoui/art/miscellaneous/rateicon.dds",
        "/esoui/art/miscellaneous/rightpanel_bg_left.dds",
        "/esoui/art/miscellaneous/rightpanel_bg_right.dds",
        "/esoui/art/miscellaneous/scrollbox_track.dds",
        "/esoui/art/miscellaneous/search_icon.dds",
        "/esoui/art/miscellaneous/singlelinesection_left.dds",
        "/esoui/art/miscellaneous/singlelinesection_right.dds",
        "/esoui/art/miscellaneous/slider_marker_down.dds",
        "/esoui/art/miscellaneous/slider_marker_over.dds",
        "/esoui/art/miscellaneous/slider_marker_up.dds",
        "/esoui/art/miscellaneous/slottingframe_vertical_bottom.dds",
        "/esoui/art/miscellaneous/slottingframe_vertical_middle.dds",
        "/esoui/art/miscellaneous/slottingframe_vertical_top.dds",
        "/esoui/art/miscellaneous/spinnerarrow_left_over.dds",
        "/esoui/art/miscellaneous/spinnerarrow_right_over.dds",
        "/esoui/art/miscellaneous/spinnerbg_left.dds",
        "/esoui/art/miscellaneous/spinnerbg_right.dds",
        "/esoui/art/miscellaneous/spinnerminus_disabled.dds",
        "/esoui/art/miscellaneous/spinnerminus_down.dds",
        "/esoui/art/miscellaneous/spinnerminus_over.dds",
        "/esoui/art/miscellaneous/spinnerminus_up.dds",
        "/esoui/art/miscellaneous/spinnerplus_disabled.dds",
        "/esoui/art/miscellaneous/spinnerplus_down.dds",
        "/esoui/art/miscellaneous/spinnerplus_over.dds",
        "/esoui/art/miscellaneous/spinnerplus_up.dds",
        "/esoui/art/miscellaneous/textentry_dropdown_center.dds",
        "/esoui/art/miscellaneous/textentry_dropdown_edge.dds",
        "/esoui/art/miscellaneous/textentry_highlight_edge.dds",
        "/esoui/art/miscellaneous/timerbar_genericfill_gloss.dds",
        "/esoui/art/miscellaneous/timerbar_genericfill_leadingedge_gloss.dds",
        "/esoui/art/miscellaneous/titledeco_left.dds",
        "/esoui/art/miscellaneous/titledeco_right.dds",
        "/esoui/art/miscellaneous/top_bar.dds",
        "/esoui/art/miscellaneous/transform_arrow.dds",
        "/esoui/art/miscellaneous/tutorial_highlight_edge.dds",
        "/esoui/art/miscellaneous/unlocked_down.dds",
        "/esoui/art/miscellaneous/unlocked_over.dds",
        "/esoui/art/miscellaneous/unlocked_up.dds",
        "/esoui/art/miscellaneous/wait_icon.dds",
        "/esoui/art/miscellaneous/wide_divider_left.dds",
        "/esoui/art/miscellaneous/wide_divider_right.dds",
        "/esoui/art/miscellaneous/window_bg_falloff.dds",
        "/esoui/art/miscellaneous/window_edge.dds",
        "/esoui/art/mounts/activemount_icon.dds",
        "/esoui/art/mounts/feed_icon.dds",
        "/esoui/art/mounts/mountportait_empty.dds",
        "/esoui/art/mounts/mounts_apple_disabled.dds",
        "/esoui/art/mounts/mounts_apple_down.dds",
        "/esoui/art/mounts/mounts_apple_over.dds",
        "/esoui/art/mounts/mounts_apple_up.dds",
        "/esoui/art/mounts/mounts_hay_disabled.dds",
        "/esoui/art/mounts/mounts_hay_down.dds",
        "/esoui/art/mounts/mounts_hay_over.dds",
        "/esoui/art/mounts/mounts_hay_up.dds",
        "/esoui/art/mounts/mounts_oats_disabled.dds",
        "/esoui/art/mounts/mounts_oats_down.dds",
        "/esoui/art/mounts/mounts_oats_over.dds",
        "/esoui/art/mounts/mounts_oats_up.dds",
        "/esoui/art/mounts/tabicon_mounts_disabled.dds",
        "/esoui/art/mounts/tabicon_mounts_down.dds",
        "/esoui/art/mounts/tabicon_mounts_over.dds",
        "/esoui/art/mounts/tabicon_mounts_up.dds",
        "/esoui/art/mounts/timer_icon.dds",
        "/esoui/art/mounts/timer_overlay.dds",
        "/esoui/art/notifications/notificationicon_campaignqueue.dds",
        "/esoui/art/notifications/notificationicon_friend.dds",
        "/esoui/art/notifications/notificationicon_group.dds",
        "/esoui/art/notifications/notificationicon_guild.dds",
        "/esoui/art/notifications/notificationicon_leaderboard.dds",
        "/esoui/art/notifications/notificationicon_mara.dds",
        "/esoui/art/notifications/notificationicon_quest.dds",
        "/esoui/art/notifications/notificationicon_resurrect.dds",
        "/esoui/art/notifications/notificationicon_trade.dds",
        "/esoui/art/notifications/notification_cs.dds",
        "/esoui/art/notifications/notification_leaderboardaccept_down.dds",
        "/esoui/art/notifications/notification_leaderboardaccept_over.dds",
        "/esoui/art/notifications/notification_leaderboardaccept_up.dds",
        "/esoui/art/perks/perks_tabicon_battle_inactive.dds",
        "/esoui/art/perks/perks_tabicon_inherent_inactive.dds",
        "/esoui/art/perks/perks_tabicon_social_inactive.dds",
        "/esoui/art/progression/abilitybar_divider.dds",
        "/esoui/art/progression/abilityframe_empty.dds",
        "/esoui/art/progression/abilityframe_filled.dds",
        "/esoui/art/progression/ability_line.dds",
        "/esoui/art/progression/ability_tree_left.dds",
        "/esoui/art/progression/ability_tree_right.dds",
        "/esoui/art/progression/addpoints_down.dds",
        "/esoui/art/progression/addpoints_over.dds",
        "/esoui/art/progression/addpoints_up.dds",
        "/esoui/art/progression/headerbg.dds",
        "/esoui/art/progression/health_points_frame.dds",
        "/esoui/art/progression/icon_1handed.dds",
        "/esoui/art/progression/icon_1handplusrune.dds",
        "/esoui/art/progression/icon_2handed.dds",
        "/esoui/art/progression/icon_alchemist.dds",
        "/esoui/art/progression/icon_armorsmith.dds",
        "/esoui/art/progression/icon_bows.dds",
        "/esoui/art/progression/icon_dualwield.dds",
        "/esoui/art/progression/icon_enchanter.dds",
        "/esoui/art/progression/icon_firestaff.dds",
        "/esoui/art/progression/icon_healstaff.dds",
        "/esoui/art/progression/icon_icestaff.dds",
        "/esoui/art/progression/icon_lightningstaff.dds",
        "/esoui/art/progression/icon_provisioner.dds",
        "/esoui/art/progression/icon_weaponsmith.dds",
        "/esoui/art/progression/levelup_progbar_frame.dds",
        "/esoui/art/progression/list_header_bg.dds",
        "/esoui/art/progression/lock.dds",
        "/esoui/art/progression/magicka_points_frame.dds",
        "/esoui/art/progression/morph_disabled.dds",
        "/esoui/art/progression/morph_down.dds",
        "/esoui/art/progression/morph_graphic.dds",
        "/esoui/art/progression/morph_over.dds",
        "/esoui/art/progression/morph_up.dds",
        "/esoui/art/progression/passiveability_frame_bottom.dds",
        "/esoui/art/progression/passiveability_frame_top.dds",
        "/esoui/art/progression/passive_arrow_graphic.dds",
        "/esoui/art/progression/progressbar_genericglow.dds",
        "/esoui/art/progression/progression_crafting_1stentry_bg.dds",
        "/esoui/art/progression/progression_crafting_delevel_down.dds",
        "/esoui/art/progression/progression_crafting_delevel_over.dds",
        "/esoui/art/progression/progression_crafting_delevel_up.dds",
        "/esoui/art/progression/progression_crafting_entry_bg.dds",
        "/esoui/art/progression/progression_crafting_locked_down.dds",
        "/esoui/art/progression/progression_crafting_locked_over.dds",
        "/esoui/art/progression/progression_crafting_locked_up.dds",
        "/esoui/art/progression/progression_crafting_unlocked_down.dds",
        "/esoui/art/progression/progression_crafting_unlocked_over.dds",
        "/esoui/art/progression/progression_crafting_unlocked_up.dds",
        "/esoui/art/progression/progression_indexicon_armor_down.dds",
        "/esoui/art/progression/progression_indexicon_armor_over.dds",
        "/esoui/art/progression/progression_indexicon_armor_up.dds",
        "/esoui/art/progression/progression_indexicon_ava_down.dds",
        "/esoui/art/progression/progression_indexicon_ava_over.dds",
        "/esoui/art/progression/progression_indexicon_ava_up.dds",
        "/esoui/art/progression/progression_indexicon_class_down.dds",
        "/esoui/art/progression/progression_indexicon_class_over.dds",
        "/esoui/art/progression/progression_indexicon_class_up.dds",
        "/esoui/art/progression/progression_indexicon_guilds_down.dds",
        "/esoui/art/progression/progression_indexicon_guilds_over.dds",
        "/esoui/art/progression/progression_indexicon_guilds_up.dds",
        "/esoui/art/progression/progression_indexicon_race_down.dds",
        "/esoui/art/progression/progression_indexicon_race_over.dds",
        "/esoui/art/progression/progression_indexicon_race_up.dds",
        "/esoui/art/progression/progression_indexicon_tradeskills_down.dds",
        "/esoui/art/progression/progression_indexicon_tradeskills_over.dds",
        "/esoui/art/progression/progression_indexicon_tradeskills_up.dds",
        "/esoui/art/progression/progression_indexicon_weapons_down.dds",
        "/esoui/art/progression/progression_indexicon_weapons_over.dds",
        "/esoui/art/progression/progression_indexicon_weapons_up.dds",
        "/esoui/art/progression/progression_indexicon_world_down.dds",
        "/esoui/art/progression/progression_indexicon_world_over.dds",
        "/esoui/art/progression/progression_indexicon_world_up.dds",
        "/esoui/art/progression/progression_progbar_genericfill.dds",
        "/esoui/art/progression/progression_progbar_leadingedge.dds",
        "/esoui/art/progression/progression_tabicon_active_active.dds",
        "/esoui/art/progression/progression_tabicon_active_inactive.dds",
        "/esoui/art/progression/progression_tabicon_backup_active.dds",
        "/esoui/art/progression/progression_tabicon_backup_inactive.dds",
        "/esoui/art/progression/progression_tabicon_backup_over.dds",
        "/esoui/art/progression/progression_tabicon_combatskills_down.dds",
        "/esoui/art/progression/progression_tabicon_combatskills_over.dds",
        "/esoui/art/progression/progression_tabicon_combatskills_up.dds",
        "/esoui/art/progression/progression_tabicon_passive_active.dds",
        "/esoui/art/progression/progression_tabicon_passive_inactive.dds",
        "/esoui/art/progression/progression_tabicon_weapons_active.dds",
        "/esoui/art/progression/progression_tabicon_weapons_inactive.dds",
        "/esoui/art/progression/skillpoint_header_bg.dds",
        "/esoui/art/progression/skyshard_1.dds",
        "/esoui/art/progression/skyshard_2.dds",
        "/esoui/art/progression/skyshard_3.dds",
        "/esoui/art/progression/skyshard_base.dds",
        "/esoui/art/progression/stamina_points_frame.dds",
        "/esoui/art/progression/veteranicon_large.dds",
        "/esoui/art/progression/veteranicon_small.dds",
        "/esoui/art/quest/map_configure_disabled.dds",
        "/esoui/art/quest/map_configure_down.dds",
        "/esoui/art/quest/map_configure_up.dds",
        "/esoui/art/quest/map_respawnareapin.dds",
        "/esoui/art/quest/questjournal_divider.dds",
        "/esoui/art/quest/questjournal_inset_left.dds",
        "/esoui/art/quest/questjournal_inset_right.dds",
        "/esoui/art/quest/questjournal_trackedquest_icon.dds",
        "/esoui/art/quest/quest_abandon_disabled.dds",
        "/esoui/art/quest/quest_abandon_down.dds",
        "/esoui/art/quest/quest_abandon_up.dds",
        "/esoui/art/quest/quest_assist_down.dds",
        "/esoui/art/quest/quest_assist_up.dds",
        "/esoui/art/quest/quest_share_disabled.dds",
        "/esoui/art/quest/quest_share_down.dds",
        "/esoui/art/quest/quest_share_up.dds",
        "/esoui/art/quest/quest_showonmap_disabled.dds",
        "/esoui/art/quest/quest_showonmap_down.dds",
        "/esoui/art/quest/quest_showonmap_up.dds",
        "/esoui/art/quest/quest_track_disabled.dds",
        "/esoui/art/quest/quest_track_down.dds",
        "/esoui/art/quest/quest_track_up.dds",
        "/esoui/art/quest/quest_untrack_disabled.dds",
        "/esoui/art/quest/quest_untrack_down.dds",
        "/esoui/art/quest/quest_untrack_up.dds",
        "/esoui/art/quest/tracked_pin.dds",
        "/esoui/art/quest/tracker_currentquest_bullet.dds",
        "/esoui/art/quickslots/quickslot_dragslot.dds",
        "/esoui/art/quickslots/quickslot_emptyslot.dds",
        "/esoui/art/quickslots/quickslot_highlight_blob.dds",
        "/esoui/art/quickslots/quickslot_mapping_bg.dds",
        "/esoui/art/repair/inventory_tabicon_repair_disabled.dds",
        "/esoui/art/repair/inventory_tabicon_repair_down.dds",
        "/esoui/art/repair/inventory_tabicon_repair_over.dds",
        "/esoui/art/repair/inventory_tabicon_repair_up.dds",
        "/esoui/art/reticle/reticleanim.dds",
        "/esoui/art/screens/loadscreen_bottommunge_tile.dds",
        "/esoui/art/screens/loadscreen_topmunge_tile.dds",
        "/esoui/art/screens_app/interactkeyframe_center.dds",
        "/esoui/art/screens_app/interactkeyframe_edge.dds",
        "/esoui/art/screens_app/loadscreen_bottommunge_tile.dds",
        "/esoui/art/screens_app/loadscreen_ouroboros.dds",
        "/esoui/art/screens_app/loadscreen_title.dds",
        "/esoui/art/screens_app/loadscreen_topmunge_tile.dds",
        "/esoui/art/screens_app/load_ourosboros.dds",
        "/esoui/art/stats/alliancebadge_aldmeri.dds",
        "/esoui/art/stats/alliancebadge_daggerfall.dds",
        "/esoui/art/stats/alliancebadge_ebonheart.dds",
        "/esoui/art/stats/diminishingreturns_icon.dds",
        "/esoui/art/stats/stats_healthbar.dds",
        "/esoui/art/stats/stats_magickabar.dds",
        "/esoui/art/stats/stats_staminabar.dds",
        "/esoui/art/stealth/stealth_64.dds",
        "/esoui/art/tabs/bottom_tab_active.dds",
        "/esoui/art/tabs/bottom_tab_highlightblob.dds",
        "/esoui/art/tabs/bottom_tab_inactive.dds",
        "/esoui/art/tabs/bottom_tab_inactive_mousedown.dds",
        "/esoui/art/tabs/bottom_tab_inactive_mouseover.dds",
        "/esoui/art/tabs/tab_chat_active.dds",
        "/esoui/art/tabs/tab_top_active.dds",
        "/esoui/art/tabs/tab_top_highlightblob.dds",
        "/esoui/art/tabs/tab_top_inactive.dds",
        "/esoui/art/tabs/tab_top_inactive_disabled.dds",
        "/esoui/art/tabs/tab_top_inactive_mousedown.dds",
        "/esoui/art/tabs/tab_top_inactive_mouseover.dds",
        "/esoui/art/tooltips/arrow_down.dds",
        "/esoui/art/tooltips/icon_bag.dds",
        "/esoui/art/tooltips/icon_bank.dds",
        "/esoui/art/tooltips/munge_overlay.dds",
        "/esoui/art/tooltips/tooltip_downarrow.dds",
        "/esoui/art/tooltips/tooltip_equippedlabel_bg.dds",
        "/esoui/art/tooltips/tooltip_leftarrow.dds",
        "/esoui/art/tooltips/tooltip_rightarrow.dds",
        "/esoui/art/tooltips/tooltip_uparrow.dds",
        "/esoui/art/tradewindow/trade_additem.dds",
        "/esoui/art/tradewindow/trade_itembg_left.dds",
        "/esoui/art/tradewindow/trade_itembg_right.dds",
        "/esoui/art/tradewindow/trade_player_readybg_bottomleft.dds",
        "/esoui/art/tradewindow/trade_player_readybg_bottomright.dds",
        "/esoui/art/tradewindow/trade_player_readybg_topleft.dds",
        "/esoui/art/tradewindow/trade_player_readybg_topright.dds",
        "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_disabled.dds",
        "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_down.dds",
        "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_over.dds",
        "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_up.dds",
        "/esoui/art/tradinghouse/tradinghouse_divider_short.dds",
        "/esoui/art/tradinghouse/tradinghouse_emptysellslot_icon.dds",
        "/esoui/art/tradinghouse/tradinghouse_itemicon_highlightbg.dds",
        "/esoui/art/tradinghouse/tradinghouse_listings_tabicon_disabled.dds",
        "/esoui/art/tradinghouse/tradinghouse_listings_tabicon_down.dds",
        "/esoui/art/tradinghouse/tradinghouse_listings_tabicon_over.dds",
        "/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
        "/esoui/art/tradinghouse/tradinghouse_sellblock-bghighlight_bottom.dds",
        "/esoui/art/tradinghouse/tradinghouse_sellblock-bghighlight_top.dds",
        "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_disabled.dds",
        "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_down.dds",
        "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_over.dds",
        "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
        "/esoui/art/tutorial/tutorial_hud_windowbg.dds",
        "/esoui/art/uicombatoverlay/uicombatoverlaycenter.dds",
        "/esoui/art/uicombatoverlay/uicombatoverlayedge.dds",
        "/esoui/art/unitattributevisualizer/attributebar_arrow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_bg.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_large.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_large_glow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_small.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_small_glow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_standard.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedarmor_standard_glow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_decreasedpower_halo.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_fill.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_frame.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_healthglow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_bg.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedarmor_frame.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpowerglow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpoweroverlay_fill.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_increasedpoweroverlay_leadingedge.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_invulnerable_munge.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_magickaglow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_dynamic_staminaglow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_base.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_base_center.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_fill_center.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_frame.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_frame_center.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_glow.dds",
        "/esoui/art/unitattributevisualizer/attributebar_small_glow_center.dds",
        "/esoui/art/unitattributevisualizer/increasedpower_animatedhalo_32fr.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_bg.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_large.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_large_glow.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_small.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_small_glow.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_standard.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_decreasedarmor_standard_glow.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_fill.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_fill_gloss.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_frame.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_increasedarmor_bg.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_increasedarmor_frame.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_increasedpowerglow.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_invulnerable.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge.dds",
        "/esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge_gloss.dds",
        "/esoui/art/unitframes/enemycastbar_inset_left.dds",
        "/esoui/art/unitframes/enemycastbar_inset_right.dds",
        "/esoui/art/unitframes/playercastbar_inset_left.dds",
        "/esoui/art/unitframes/playercastbar_inset_right.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level2_left.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level2_right.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level3_left.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level3_right.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level4_left.dds",
        "/esoui/art/unitframes/targetunitframe_bracket_level4_right.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level2_left.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level2_right.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level3_left.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level3_right.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level4_left.dds",
        "/esoui/art/unitframes/targetunitframe_glowoverlay_level4_right.dds",
        "/esoui/art/unitframes/targetunitframe_glowunderlay_level4_left.dds",
        "/esoui/art/unitframes/targetunitframe_glowunderlay_level4_right.dds",
        "/esoui/art/unitframes/target_health_frame.dds",
        "/esoui/art/unitframes/target_name_bracket_left.dds",
        "/esoui/art/unitframes/target_name_bracket_right.dds",
        "/esoui/art/unitframes/target_veteranrank_icon.dds",
        "/esoui/art/unitframes/unitframe_player.dds",
        "/esoui/art/unitframes/unitframe_target_left.dds",
        "/esoui/art/unitframes/unitframe_target_right.dds",
        "/esoui/art/vendor/vendor_tabicon_buyback_down.dds",
        "/esoui/art/vendor/vendor_tabicon_buyback_over.dds",
        "/esoui/art/vendor/vendor_tabicon_buyback_up.dds",
        "/esoui/art/vendor/vendor_tabicon_buy_down.dds",
        "/esoui/art/vendor/vendor_tabicon_buy_over.dds",
        "/esoui/art/vendor/vendor_tabicon_buy_up.dds",
        "/esoui/art/vendor/vendor_tabicon_repair_down.dds",
        "/esoui/art/vendor/vendor_tabicon_repair_over.dds",
        "/esoui/art/vendor/vendor_tabicon_repair_up.dds",
        "/esoui/art/vendor/vendor_tabicon_sell_down.dds",
        "/esoui/art/vendor/vendor_tabicon_sell_over.dds",
        "/esoui/art/vendor/vendor_tabicon_sell_up.dds",
        "/esoui/art/voip/voip_currentspeaker.dds",
        "/esoui/art/worldmap/mapnav_downarrow_over.dds",
        "/esoui/art/worldmap/mapnav_uparrow_over.dds",
        "/esoui/art/worldmap/map_ava_panelbg.dds",
        "/esoui/art/worldmap/map_ava_tabicon_foodfarm_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_foodfarm_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_foodfarm_up.dds",
        "/esoui/art/worldmap/map_ava_tabicon_keepsummary_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_keepsummary_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_keepsummary_up.dds",
        "/esoui/art/worldmap/map_ava_tabicon_oremine_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_oremine_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_oremine_up.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourcedefense_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourcedefense_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourcedefense_up.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourceproduction_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourceproduction_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_resourceproduction_up.dds",
        "/esoui/art/worldmap/map_ava_tabicon_woodmill_down.dds",
        "/esoui/art/worldmap/map_ava_tabicon_woodmill_over.dds",
        "/esoui/art/worldmap/map_ava_tabicon_woodmill_up.dds",
        "/esoui/art/worldmap/map_backdrop_center.dds",
        "/esoui/art/worldmap/map_centerreticle.dds",
        "/esoui/art/worldmap/map_indexicon_filters_down.dds",
        "/esoui/art/worldmap/map_indexicon_filters_over.dds",
        "/esoui/art/worldmap/map_indexicon_filters_up.dds",
        "/esoui/art/worldmap/map_indexicon_key_down.dds",
        "/esoui/art/worldmap/map_indexicon_key_over.dds",
        "/esoui/art/worldmap/map_indexicon_key_up.dds",
        "/esoui/art/worldmap/map_indexicon_locations_down.dds",
        "/esoui/art/worldmap/map_indexicon_locations_over.dds",
        "/esoui/art/worldmap/map_indexicon_locations_up.dds",
        "/esoui/art/worldmap/map_indexicon_quests_down.dds",
        "/esoui/art/worldmap/map_indexicon_quests_over.dds",
        "/esoui/art/worldmap/map_indexicon_quests_up.dds",
        "/esoui/art/worldmap/selectedquesthighlight.dds",
        "/esoui/art/worldmap/worldmap_frame_edge.dds",
        "/esoui/art/worldmap/worldmap_map_background.dds",
        "/esoui/art/worldmap/worldmap_map_edge.dds",
    }

	LWF4.data.GameSounds = {}
	for k,v in pairs( SOUNDS ) do
		LWF4.data.GameSounds[tostring(k)] = { desc = tostring( v ), parm = v }
	end
	LWF4.data.GameSoundsByIndex = {}
	local ix = 0
	for k,t in kPairs( LWF4.data.GameSounds ) do
		ix = ix+1
		LWF4.data.GameSoundsByIndex[ ix ] = k
	end

	LWF4.data.Fonts = {
		["Arial Narrow"]		= "EsoUI/Common/Fonts/univers55.otf",
		["Consolas"]			= "EsoUI/Common/Fonts/consola.ttf",
		["ESO Cartographer"]	= "EsoUI/Common/Fonts/univers57.otf",
		["Fontin Bold"]			= "EsoUI/Common/Fonts/univers55.otf",
		["Fontin Italic"]		= "EsoUI/Common/Fonts/univers55.otf",
		["Fontin Regular"]		= "EsoUI/Common/Fonts/univers55.otf",
		["Fontin SmallCaps"]	= "EsoUI/Common/Fonts/univers55.otf",
		["Futura Condensed"]	= "EsoUI/Common/Fonts/futurastd-condensed.otf",
		["Futura Light"]		= "EsoUI/Common/Fonts/futurastd-condensedlight.otf",
		["ProseAntique"]		= "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
		["Skyrim Handwritten"]	= "EsoUI/Common/Fonts/Handwritten_Bold.otf",
		["Trajan Pro"]			= "EsoUI/Common/Fonts/trajanpro-regular.otf",
		["Univers 55"]			= "EsoUI/Common/Fonts/univers55.otf",
		["Univers 57"]			= "EsoUI/Common/Fonts/univers57.otf",
		["Univers 67"]			= "EsoUI/Common/Fonts/univers67.otf",
	}

	LWF4.data.KeyMap = {
		[KEY_0] = "0",
		[KEY_1] = "1",
		[KEY_2] = "2",
		[KEY_3] = "3",
		[KEY_4] = "4",
		[KEY_5] = "5",
		[KEY_6] = "6",
		[KEY_7] = "7",
		[KEY_8] = "8",
		[KEY_9] = "9",
		[KEY_A] = "A",
		[KEY_B] = "B",
		[KEY_BACKSPACE] = "BACKSPACE",
		[KEY_C] = "C",
		[KEY_CAPSLOCK] = "CAPSLOCK",
		[KEY_D] = "D",
		[KEY_DELETE] = "DELETE",
		[KEY_DOWNARROW] = "DOWN ARROW",
		[KEY_E] = "E",
		[KEY_END] = "END",
		[KEY_F] = "F",
		[KEY_F10] = "F10",
		[KEY_F11] = "F11",
		[KEY_F12] = "F12",
		[KEY_F13] = "F13",
		[KEY_F14] = "F14",
		[KEY_F15] = "F15",
		[KEY_F16] = "F16",
		[KEY_F17] = "F17",
		[KEY_F18] = "F18",
		[KEY_F19] = "F19",
		[KEY_F2] = "F2",
		[KEY_F20] = "F20",
		[KEY_F21] = "F21",
		[KEY_F22] = "F22",
		[KEY_F23] = "F23",
		[KEY_F24] = "F24",
		[KEY_F3] = "F3",
		[KEY_F4] = "F4",
		[KEY_F5] = "F5",
		[KEY_F6] = "F6",
		[KEY_F7] = "F7",
		[KEY_F8] = "F8",
		[KEY_F9] = "F9",
		[KEY_G] = "G",
		[KEY_H] = "H",
		[KEY_HOME] = "HOME",
		[KEY_I] = "I",
		[KEY_INSERT] = "INSERT",
		[KEY_INVALID] = "INVALID",
		[KEY_J] = "J",
		[KEY_K] = "K",
		[KEY_L] = "L",
		[KEY_LEFTARROW] = "LEFT ARROW",
		[KEY_LWINDOWS] = "LEFT WINDOWS",
		[KEY_M] = "M",
		[KEY_N] = "N",
		[KEY_NUMPAD0] = "NUMPAD 0",
		[KEY_NUMPAD1] = "NUMPAD 1",
		[KEY_NUMPAD2] = "NUMPAD 2",
		[KEY_NUMPAD3] = "NUMPAD 3",
		[KEY_NUMPAD4] = "NUMPAD 4",
		[KEY_NUMPAD5] = "NUMPAD 5",
		[KEY_NUMPAD6] = "NUMPAD 6",
		[KEY_NUMPAD7] = "NUMPAD 7",
		[KEY_NUMPAD8] = "NUMPAD 8",
		[KEY_NUMPAD9] = "NUMPAD 9",
		[KEY_NUMPAD_ADD] = "NUMPAD PLUS",
		[KEY_NUMPAD_DOT] = "NUMPAD DOT",
		[KEY_NUMPAD_ENTER] = "NUMPAD ENTER",
		[KEY_NUMPAD_MINUS] = "NUMPAD MINUS",
		[KEY_NUMPAD_SLASH] = "NUMPAD SLASH",
		[KEY_NUMPAD_STAR] = "NUMPAD STAR",
		[KEY_O] = "O",
		[KEY_OEM_102_GERMAN_LESS_THAN] = "0",
		[KEY_OEM_1_SEMICOLON] = ";",
		[KEY_OEM_2_FORWARD_SLASH] = "//",
		[KEY_OEM_3_TICK] = "`",
		[KEY_OEM_4_LEFT_SQUARE_BRACKET] = "[",
		[KEY_OEM_5_BACK_SLASH] = "\\",
		[KEY_OEM_6_RIGHT_SQUARE_BRACKET] = "]]",
		[KEY_OEM_7_SINGLE_QUOTE] = "'",
		[KEY_OEM_COMMA] = ",",
		[KEY_OEM_MINUS] = "-",
		[KEY_OEM_PERIOD] = ".",
		[KEY_OEM_PLUS] = "=",
		[KEY_P] = "P",
		[KEY_PAGEDOWN] = "PAGE DOWN",
		[KEY_PAGEUP] = "PAGE UP",
		[KEY_PAUSE] = "PAUSE",
		[KEY_PRINTSCREEN] = "PRINT SCREEN",
		[KEY_Q] = "Q",
		[KEY_R] = "R",
		[KEY_RIGHTARROW] = "RIGHT ARROW",
		[KEY_RWINDOWS] = "RIGHT WINDOWS",
		[KEY_S] = "S",
		[KEY_SCROLLLOCK] = "SCROLL LOCK",
		[KEY_SPACEBAR] = "SPACE",
		[KEY_T] = "T",
		[KEY_TAB] = "TAB",
		[KEY_U] = "U",
		[KEY_UPARROW] = "UP ARROW",
		[KEY_V] = "V",
		[KEY_W] = "W",
		[KEY_X] = "X",
		[KEY_Y] = "Y",
		[KEY_Z] = "Z",
		[KEY_SHIFT] = "SHIFT",
	}

	LWF4.data.GameEventTable = {
        ["EVENT_ABILITY_COOLDOWN_UPDATED"] = {
            CODE=EVENT_ABILITY_COOLDOWN_UPDATED,
            DESCR="EVENT_ABILITY_COOLDOWN_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                abilityId={ dataType="integer", name="abilityId", paramNum=2 },
            },
        },
        ["EVENT_ABILITY_LIST_CHANGED"] = {
            CODE=EVENT_ABILITY_LIST_CHANGED,
            DESCR="EVENT_ABILITY_LIST_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ABILITY_PROGRESSION_RANK_UPDATE"] = {
            CODE=EVENT_ABILITY_PROGRESSION_RANK_UPDATE,
            DESCR="EVENT_ABILITY_PROGRESSION_RANK_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                progressionIndex={ dataType="luaindex", name="progressionIndex", paramNum=2 },
                rank={ dataType="integer", name="rank", paramNum=3 },
                maxRank={ dataType="integer", name="maxRank", paramNum=4 },
                morph={ dataType="integer", name="morph", paramNum=5 },
            },
        },
        ["EVENT_ABILITY_PROGRESSION_RESULT"] = {
            CODE=EVENT_ABILITY_PROGRESSION_RESULT,
            DESCR="EVENT_ABILITY_PROGRESSION_RESULT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_ABILITY_PROGRESSION_XP_UPDATE"] = {
            CODE=EVENT_ABILITY_PROGRESSION_XP_UPDATE,
            DESCR="EVENT_ABILITY_PROGRESSION_XP_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                progressionIndex={ dataType="luaindex", name="progressionIndex", paramNum=2 },
                lastRankXP={ dataType="integer", name="lastRankXP", paramNum=3 },
                nextRankXP={ dataType="integer", name="nextRankXP", paramNum=4 },
                currentXP={ dataType="integer", name="currentXP", paramNum=5 },
                atMorph={ dataType="bool", name="atMorph", paramNum=6 },
            },
        },
        ["EVENT_ABILITY_REQUIREMENTS_FAIL"] = {
            CODE=EVENT_ABILITY_REQUIREMENTS_FAIL,
            DESCR="EVENT_ABILITY_REQUIREMENTS_FAIL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                errorId={ dataType="integer", name="errorId", paramNum=2 },
            },
        },
        ["EVENT_ACHIEVEMENTS_UPDATED"] = {
            CODE=EVENT_ACHIEVEMENTS_UPDATED,
            DESCR="EVENT_ACHIEVEMENTS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ACHIEVEMENT_AWARDED"] = {
            CODE=EVENT_ACHIEVEMENT_AWARDED,
            DESCR="EVENT_ACHIEVEMENT_AWARDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                name={ dataType="string", name="name", paramNum=2 },
                points={ dataType="integer", name="points", paramNum=3 },
                id={ dataType="integer", name="id", paramNum=4 },
                link={ dataType="string", name="link", paramNum=5 },
            },
        },
        ["EVENT_ACHIEVEMENT_UPDATED"] = {
            CODE=EVENT_ACHIEVEMENT_UPDATED,
            DESCR="EVENT_ACHIEVEMENT_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                id={ dataType="integer", name="id", paramNum=2 },
            },
        },
        ["EVENT_ACTION_SLOTS_FULL_UPDATE"] = {
            CODE=EVENT_ACTION_SLOTS_FULL_UPDATE,
            DESCR="EVENT_ACTION_SLOTS_FULL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                isHotbarSwap={ dataType="bool", name="isHotbarSwap", paramNum=2 },
            },
        },
        ["EVENT_ACTION_SLOT_ABILITY_SLOTTED"] = {
            CODE=EVENT_ACTION_SLOT_ABILITY_SLOTTED,
            DESCR="EVENT_ACTION_SLOT_ABILITY_SLOTTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newAbilitySlotted={ dataType="bool", name="newAbilitySlotted", paramNum=2 },
            },
        },
        ["EVENT_ACTION_SLOT_STATE_UPDATED"] = {
            CODE=EVENT_ACTION_SLOT_STATE_UPDATED,
            DESCR="EVENT_ACTION_SLOT_STATE_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotNum={ dataType="luaindex", name="slotNum", paramNum=2 },
            },
        },
        ["EVENT_ACTION_SLOT_UPDATED"] = {
            CODE=EVENT_ACTION_SLOT_UPDATED,
            DESCR="EVENT_ACTION_SLOT_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotNum={ dataType="luaindex", name="slotNum", paramNum=2 },
            },
        },
        ["EVENT_ACTION_UPDATE_COOLDOWNS"] = {
            CODE=EVENT_ACTION_UPDATE_COOLDOWNS,
            DESCR="EVENT_ACTION_UPDATE_COOLDOWNS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ACTIVE_QUEST_TOOL_CHANGED"] = {
            CODE=EVENT_ACTIVE_QUEST_TOOL_CHANGED,
            DESCR="EVENT_ACTIVE_QUEST_TOOL_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                toolIndex={ dataType="luaindex", name="toolIndex", paramNum=3 },
            },
        },
        ["EVENT_ACTIVE_QUEST_TOOL_CLEARED"] = {
            CODE=EVENT_ACTIVE_QUEST_TOOL_CLEARED,
            DESCR="EVENT_ACTIVE_QUEST_TOOL_CLEARED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ACTIVE_QUICKSLOT_CHANGED"] = {
            CODE=EVENT_ACTIVE_QUICKSLOT_CHANGED,
            DESCR="EVENT_ACTIVE_QUICKSLOT_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotId={ dataType="integer", name="slotId", paramNum=2 },
            },
        },
        ["EVENT_ACTIVE_WEAPON_PAIR_CHANGED"] = {
            CODE=EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
            DESCR="EVENT_ACTIVE_WEAPON_PAIR_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                activeWeaponPair={ dataType="integer", name="activeWeaponPair", paramNum=2 },
                locked={ dataType="bool", name="locked", paramNum=3 },
            },
        },
        ["EVENT_AGENT_CHAT_ACCEPTED"] = {
            CODE=EVENT_AGENT_CHAT_ACCEPTED,
            DESCR="EVENT_AGENT_CHAT_ACCEPTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_AGENT_CHAT_DECLINED"] = {
            CODE=EVENT_AGENT_CHAT_DECLINED,
            DESCR="EVENT_AGENT_CHAT_DECLINED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_AGENT_CHAT_FORCED"] = {
            CODE=EVENT_AGENT_CHAT_FORCED,
            DESCR="EVENT_AGENT_CHAT_FORCED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_AGENT_CHAT_REQUESTED"] = {
            CODE=EVENT_AGENT_CHAT_REQUESTED,
            DESCR="EVENT_AGENT_CHAT_REQUESTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_AGENT_CHAT_TERMINATED"] = {
            CODE=EVENT_AGENT_CHAT_TERMINATED,
            DESCR="EVENT_AGENT_CHAT_TERMINATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ALLIANCE_POINT_UPDATE"] = {
            CODE=EVENT_ALLIANCE_POINT_UPDATE,
            DESCR="EVENT_ALLIANCE_POINT_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                alliancePoints={ dataType="integer", name="alliancePoints", paramNum=2 },
                playSound={ dataType="bool", name="playSound", paramNum=3 },
                difference={ dataType="integer", name="difference", paramNum=4 },
            },
        },
        ["EVENT_ARTIFACT_CONTROL_STATE"] = {
            CODE=EVENT_ARTIFACT_CONTROL_STATE,
            DESCR="EVENT_ARTIFACT_CONTROL_STATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                artifactName={ dataType="string", name="artifactName", paramNum=2 },
                keepId={ dataType="integer", name="keepId", paramNum=3 },
                playerName={ dataType="string", name="playerName", paramNum=4 },
                playerAlliance={ dataType="integer", name="playerAlliance", paramNum=5 },
                controlEvent={ dataType="integer", name="controlEvent", paramNum=6 },
                controlState={ dataType="integer", name="controlState", paramNum=7 },
                campaignId={ dataType="integer", name="campaignId", paramNum=8 },
            },
        },
        ["EVENT_ASSIGNED_CAMPAIGN_CHANGED"] = {
            CODE=EVENT_ASSIGNED_CAMPAIGN_CHANGED,
            DESCR="EVENT_ASSIGNED_CAMPAIGN_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newAssignedCampaignId={ dataType="integer", name="newAssignedCampaignId", paramNum=2 },
            },
        },
        ["EVENT_ATTRIBUTE_FORCE_RESPEC"] = {
            CODE=EVENT_ATTRIBUTE_FORCE_RESPEC,
            DESCR="EVENT_ATTRIBUTE_FORCE_RESPEC",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                note={ dataType="string", name="note", paramNum=2 },
            },
        },
        ["EVENT_ATTRIBUTE_UPGRADE_UPDATED"] = {
            CODE=EVENT_ATTRIBUTE_UPGRADE_UPDATED,
            DESCR="EVENT_ATTRIBUTE_UPGRADE_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_AVENGE_KILL"] = {
            CODE=EVENT_AVENGE_KILL,
            DESCR="EVENT_AVENGE_KILL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                avengedPlayerName={ dataType="string", name="avengedPlayerName", paramNum=2 },
                killedPlayerName={ dataType="string", name="killedPlayerName", paramNum=3 },
            },
        },
        ["EVENT_BANKED_MONEY_UPDATE"] = {
            CODE=EVENT_BANKED_MONEY_UPDATE,
            DESCR="EVENT_BANKED_MONEY_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newBankedMoney={ dataType="integer", name="newBankedMoney", paramNum=2 },
                oldBankedMoney={ dataType="integer", name="oldBankedMoney", paramNum=3 },
            },
        },
        ["EVENT_BANK_IS_FULL"] = {
            CODE=EVENT_BANK_IS_FULL,
            DESCR="EVENT_BANK_IS_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BATTLE_STANDARDS_UPDATED"] = {
            CODE=EVENT_BATTLE_STANDARDS_UPDATED,
            DESCR="EVENT_BATTLE_STANDARDS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BEGIN_LOCKPICK"] = {
            CODE=EVENT_BEGIN_LOCKPICK,
            DESCR="EVENT_BEGIN_LOCKPICK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BEGIN_SIEGE_CONTROL"] = {
            CODE=EVENT_BEGIN_SIEGE_CONTROL,
            DESCR="EVENT_BEGIN_SIEGE_CONTROL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BEGIN_SIEGE_UPGRADE"] = {
            CODE=EVENT_BEGIN_SIEGE_UPGRADE,
            DESCR="EVENT_BEGIN_SIEGE_UPGRADE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BOSSES_CHANGED"] = {
            CODE=EVENT_BOSSES_CHANGED,
            DESCR="EVENT_BOSSES_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_BROADCAST"] = {
            CODE=EVENT_BROADCAST,
            DESCR="EVENT_BROADCAST",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                message={ dataType="string", name="message", paramNum=2 },
            },
        },
        ["EVENT_BUYBACK_RECEIPT"] = {
            CODE=EVENT_BUYBACK_RECEIPT,
            DESCR="EVENT_BUYBACK_RECEIPT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemLink={ dataType="string", name="itemLink", paramNum=2 },
                itemQuantity={ dataType="integer", name="itemQuantity", paramNum=3 },
                money={ dataType="integer", name="money", paramNum=4 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=5 },
            },
        },
        ["EVENT_BUY_RECEIPT"] = {
            CODE=EVENT_BUY_RECEIPT,
            DESCR="EVENT_BUY_RECEIPT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                entryName={ dataType="string", name="entryName", paramNum=2 },
                entryType={ dataType="integer", name="entryType", paramNum=3 },
                entryQuantity={ dataType="integer", name="entryQuantity", paramNum=4 },
                money={ dataType="integer", name="money", paramNum=5 },
                specialCurrencyType1={ dataType="integer", name="specialCurrencyType1", paramNum=6 },
                specialCurrencyInfo1={ dataType="string", name="specialCurrencyInfo1", paramNum=7 },
                specialCurrencyQuantity1={ dataType="integer", name="specialCurrencyQuantity1", paramNum=8 },
                specialCurrencyType2={ dataType="integer", name="specialCurrencyType2", paramNum=9 },
                specialCurrencyInfo2={ dataType="string", name="specialCurrencyInfo2", paramNum=10 },
                specialCurrencyQuantity2={ dataType="integer", name="specialCurrencyQuantity2", paramNum=11 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=12 },
            },
        },
        ["EVENT_CAMPAIGN_ASSIGNMENT_RESULT"] = {
            CODE=EVENT_CAMPAIGN_ASSIGNMENT_RESULT,
            DESCR="EVENT_CAMPAIGN_ASSIGNMENT_RESULT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                result={ dataType="integer", name="result", paramNum=2 },
            },
        },
        ["EVENT_CAMPAIGN_EMPEROR_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_EMPEROR_CHANGED,
            DESCR="EVENT_CAMPAIGN_EMPEROR_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
            },
        },
        ["EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED,
            DESCR="EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED,
            DESCR="EVENT_CAMPAIGN_LEADERBOARD_DATA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CAMPAIGN_QUEUE_JOINED"] = {
            CODE=EVENT_CAMPAIGN_QUEUE_JOINED,
            DESCR="EVENT_CAMPAIGN_QUEUE_JOINED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                isGroup={ dataType="bool", name="isGroup", paramNum=3 },
            },
        },
        ["EVENT_CAMPAIGN_QUEUE_LEFT"] = {
            CODE=EVENT_CAMPAIGN_QUEUE_LEFT,
            DESCR="EVENT_CAMPAIGN_QUEUE_LEFT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                isGroup={ dataType="bool", name="isGroup", paramNum=3 },
            },
        },
        ["EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,
            DESCR="EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                isGroup={ dataType="bool", name="isGroup", paramNum=3 },
                position={ dataType="integer", name="position", paramNum=4 },
            },
        },
        ["EVENT_CAMPAIGN_QUEUE_STATE_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_QUEUE_STATE_CHANGED,
            DESCR="EVENT_CAMPAIGN_QUEUE_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                isGroup={ dataType="bool", name="isGroup", paramNum=3 },
                state={ dataType="integer", name="state", paramNum=4 },
            },
        },
        ["EVENT_CAMPAIGN_SCORE_DATA_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_SCORE_DATA_CHANGED,
            DESCR="EVENT_CAMPAIGN_SCORE_DATA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CAMPAIGN_SELECTION_DATA_CHANGED"] = {
            CODE=EVENT_CAMPAIGN_SELECTION_DATA_CHANGED,
            DESCR="EVENT_CAMPAIGN_SELECTION_DATA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CAMPAIGN_STATE_INITIALIZED"] = {
            CODE=EVENT_CAMPAIGN_STATE_INITIALIZED,
            DESCR="EVENT_CAMPAIGN_STATE_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
            },
        },
        ["EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION"] = {
            CODE=EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION,
            DESCR="EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
            },
        },
        ["EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM"] = {
            CODE=EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM,
            DESCR="EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CANNOT_DO_THAT_WHILE_DEAD"] = {
            CODE=EVENT_CANNOT_DO_THAT_WHILE_DEAD,
            DESCR="EVENT_CANNOT_DO_THAT_WHILE_DEAD",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CANNOT_FISH_WHILE_SWIMMING"] = {
            CODE=EVENT_CANNOT_FISH_WHILE_SWIMMING,
            DESCR="EVENT_CANNOT_FISH_WHILE_SWIMMING",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CAPTURE_AREA_STATUS"] = {
            CODE=EVENT_CAPTURE_AREA_STATUS,
            DESCR="EVENT_CAPTURE_AREA_STATUS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                objectiveId={ dataType="integer", name="objectiveId", paramNum=3 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=4 },
                curValue={ dataType="integer", name="curValue", paramNum=5 },
                maxValue={ dataType="integer", name="maxValue", paramNum=6 },
                currentCapturePlayers={ dataType="integer", name="currentCapturePlayers", paramNum=7 },
                alliance1={ dataType="integer", name="alliance1", paramNum=8 },
                alliance2={ dataType="integer", name="alliance2", paramNum=9 },
            },
        },
        ["EVENT_CHATTER_BEGIN"] = {
            CODE=EVENT_CHATTER_BEGIN,
            DESCR="EVENT_CHATTER_BEGIN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                optionCount={ dataType="integer", name="optionCount", paramNum=2 },
            },
        },
        ["EVENT_CHATTER_END"] = {
            CODE=EVENT_CHATTER_END,
            DESCR="EVENT_CHATTER_END",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CHAT_CHANNEL_INVITE"] = {
            CODE=EVENT_CHAT_CHANNEL_INVITE,
            DESCR="EVENT_CHAT_CHANNEL_INVITE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                channelName={ dataType="string", name="channelName", paramNum=2 },
                playerName={ dataType="string", name="playerName", paramNum=3 },
            },
        },
        ["EVENT_CHAT_CHANNEL_JOIN"] = {
            CODE=EVENT_CHAT_CHANNEL_JOIN,
            DESCR="EVENT_CHAT_CHANNEL_JOIN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                channelId={ dataType="integer", name="channelId", paramNum=2 },
                customChannelId={ dataType="integer", name="customChannelId", paramNum=3 },
                channelName={ dataType="string", name="channelName", paramNum=4 },
            },
        },
        ["EVENT_CHAT_CHANNEL_LEAVE"] = {
            CODE=EVENT_CHAT_CHANNEL_LEAVE,
            DESCR="EVENT_CHAT_CHANNEL_LEAVE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                channelId={ dataType="integer", name="channelId", paramNum=2 },
                customChannelId={ dataType="integer", name="customChannelId", paramNum=3 },
                channelName={ dataType="string", name="channelName", paramNum=4 },
            },
        },
        ["EVENT_CHAT_LOG_TOGGLED"] = {
            CODE=EVENT_CHAT_LOG_TOGGLED,
            DESCR="EVENT_CHAT_LOG_TOGGLED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                opened={ dataType="bool", name="opened", paramNum=2 },
            },
        },
        ["EVENT_CHAT_MESSAGE_CHANNEL"] = {
            CODE=EVENT_CHAT_MESSAGE_CHANNEL,
            DESCR="EVENT_CHAT_MESSAGE_CHANNEL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                messageType={ dataType="integer", name="messageType", paramNum=2 },
                fromName={ dataType="string", name="fromName", paramNum=3 },
                text={ dataType="string", name="text", paramNum=4 },
                isCustomerService={ dataType="bool", name="isCustomerService", paramNum=5 },
            },
        },
        ["EVENT_CLOSE_BANK"] = {
            CODE=EVENT_CLOSE_BANK,
            DESCR="EVENT_CLOSE_BANK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CLOSE_GUILD_BANK"] = {
            CODE=EVENT_CLOSE_GUILD_BANK,
            DESCR="EVENT_CLOSE_GUILD_BANK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CLOSE_STORE"] = {
            CODE=EVENT_CLOSE_STORE,
            DESCR="EVENT_CLOSE_STORE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CLOSE_TRADING_HOUSE"] = {
            CODE=EVENT_CLOSE_TRADING_HOUSE,
            DESCR="EVENT_CLOSE_TRADING_HOUSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_COMBAT_EVENT"] = {
            CODE=EVENT_COMBAT_EVENT,
            DESCR="EVENT_COMBAT_EVENT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                result={ dataType="integer", name="result", paramNum=2 },
                isError={ dataType="bool", name="isError", paramNum=3 },
                abilityName={ dataType="string", name="abilityName", paramNum=4 },
                abilityGraphic={ dataType="integer", name="abilityGraphic", paramNum=5 },
                abilityActionSlotType={ dataType="integer", name="abilityActionSlotType", paramNum=6 },
                sourceName={ dataType="string", name="sourceName", paramNum=7 },
                sourceType={ dataType="integer", name="sourceType", paramNum=8 },
                targetName={ dataType="string", name="targetName", paramNum=9 },
                targetType={ dataType="integer", name="targetType", paramNum=10 },
                hitValue={ dataType="integer", name="hitValue", paramNum=11 },
                powerType={ dataType="integer", name="powerType", paramNum=12 },
                damageType={ dataType="integer", name="damageType", paramNum=13 },
                log={ dataType="bool", name="log", paramNum=14 },
            },
        },
        ["EVENT_CONFIRM_MUNDUS_STONE_INTERACT"] = {
            CODE=EVENT_CONFIRM_MUNDUS_STONE_INTERACT,
            DESCR="EVENT_CONFIRM_MUNDUS_STONE_INTERACT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newMundusStoneAbilityName={ dataType="string", name="newMundusStoneAbilityName", paramNum=2 },
                newMundusStoneAbilityDescription={ dataType="string", name="newMundusStoneAbilityDescription", paramNum=3 },
            },
        },
        ["EVENT_CONVERSATION_FAILED_INVENTORY_FULL"] = {
            CODE=EVENT_CONVERSATION_FAILED_INVENTORY_FULL,
            DESCR="EVENT_CONVERSATION_FAILED_INVENTORY_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CONVERSATION_FAILED_UNIQUE_ITEM"] = {
            CODE=EVENT_CONVERSATION_FAILED_UNIQUE_ITEM,
            DESCR="EVENT_CONVERSATION_FAILED_UNIQUE_ITEM",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_CONVERSATION_UPDATED"] = {
            CODE=EVENT_CONVERSATION_UPDATED,
            DESCR="EVENT_CONVERSATION_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                conversationBodyText={ dataType="string", name="conversationBodyText", paramNum=2 },
                conversationOptionCount={ dataType="integer", name="conversationOptionCount", paramNum=3 },
            },
        },
        ["EVENT_CORONATE_EMPEROR_NOTIFICATION"] = {
            CODE=EVENT_CORONATE_EMPEROR_NOTIFICATION,
            DESCR="EVENT_CORONATE_EMPEROR_NOTIFICATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                emperorName={ dataType="string", name="emperorName", paramNum=3 },
                emperorAlliance={ dataType="integer", name="emperorAlliance", paramNum=4 },
            },
        },
        ["EVENT_CRAFTING_STATION_INTERACT"] = {
            CODE=EVENT_CRAFTING_STATION_INTERACT,
            DESCR="EVENT_CRAFTING_STATION_INTERACT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                craftSkill={ dataType="integer", name="craftSkill", paramNum=2 },
                sameStation={ dataType="bool", name="sameStation", paramNum=3 },
            },
        },
        ["EVENT_CRAFT_COMPLETED"] = {
            CODE=EVENT_CRAFT_COMPLETED,
            DESCR="EVENT_CRAFT_COMPLETED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                craftSkill={ dataType="integer", name="craftSkill", paramNum=2 },
            },
        },
        ["EVENT_CRAFT_STARTED"] = {
            CODE=EVENT_CRAFT_STARTED,
            DESCR="EVENT_CRAFT_STARTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                craftSkill={ dataType="integer", name="craftSkill", paramNum=2 },
            },
        },
        ["EVENT_CURRENT_CAMPAIGN_CHANGED"] = {
            CODE=EVENT_CURRENT_CAMPAIGN_CHANGED,
            DESCR="EVENT_CURRENT_CAMPAIGN_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newCurrentCampaignId={ dataType="integer", name="newCurrentCampaignId", paramNum=2 },
            },
        },
        ["EVENT_CURSOR_DROPPED"] = {
            CODE=EVENT_CURSOR_DROPPED,
            DESCR="EVENT_CURSOR_DROPPED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                type={ dataType="integer", name="type", paramNum=2 },
                param1={ dataType="integer", name="param1", paramNum=3 },
                param2={ dataType="integer", name="param2", paramNum=4 },
                param3={ dataType="integer", name="param3", paramNum=5 },
                param4={ dataType="integer", name="param4", paramNum=6 },
                param5={ dataType="integer", name="param5", paramNum=7 },
                param6={ dataType="integer", name="param6", paramNum=8 },
            },
        },
        ["EVENT_CURSOR_PICKUP"] = {
            CODE=EVENT_CURSOR_PICKUP,
            DESCR="EVENT_CURSOR_PICKUP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                type={ dataType="integer", name="type", paramNum=2 },
                param1={ dataType="integer", name="param1", paramNum=3 },
                param2={ dataType="integer", name="param2", paramNum=4 },
                param3={ dataType="integer", name="param3", paramNum=5 },
                param4={ dataType="integer", name="param4", paramNum=6 },
                param5={ dataType="integer", name="param5", paramNum=7 },
                param6={ dataType="integer", name="param6", paramNum=8 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=9 },
            },
        },
        ["EVENT_DEPOSE_EMPEROR_NOTIFICATION"] = {
            CODE=EVENT_DEPOSE_EMPEROR_NOTIFICATION,
            DESCR="EVENT_DEPOSE_EMPEROR_NOTIFICATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                emperorName={ dataType="string", name="emperorName", paramNum=3 },
                emperorAlliance={ dataType="integer", name="emperorAlliance", paramNum=4 },
                abdication={ dataType="bool", name="abdication", paramNum=5 },
            },
        },
        ["EVENT_DIFFICULTY_LEVEL_CHANGED"] = {
            CODE=EVENT_DIFFICULTY_LEVEL_CHANGED,
            DESCR="EVENT_DIFFICULTY_LEVEL_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                difficultyLevel={ dataType="integer", name="difficultyLevel", paramNum=2 },
            },
        },
        ["EVENT_DISABLE_SIEGE_AIM_ABILITY"] = {
            CODE=EVENT_DISABLE_SIEGE_AIM_ABILITY,
            DESCR="EVENT_DISABLE_SIEGE_AIM_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_DISABLE_SIEGE_FIRE_ABILITY"] = {
            CODE=EVENT_DISABLE_SIEGE_FIRE_ABILITY,
            DESCR="EVENT_DISABLE_SIEGE_FIRE_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_DISABLE_SIEGE_PACKUP_ABILITY"] = {
            CODE=EVENT_DISABLE_SIEGE_PACKUP_ABILITY,
            DESCR="EVENT_DISABLE_SIEGE_PACKUP_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_DISCOVERY_EXPERIENCE"] = {
            CODE=EVENT_DISCOVERY_EXPERIENCE,
            DESCR="EVENT_DISCOVERY_EXPERIENCE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                areaName={ dataType="string", name="areaName", paramNum=2 },
                level={ dataType="integer", name="level", paramNum=3 },
                previousExperience={ dataType="integer", name="previousExperience", paramNum=4 },
                currentExperience={ dataType="integer", name="currentExperience", paramNum=5 },
                rank={ dataType="integer", name="rank", paramNum=6 },
                previousPoints={ dataType="integer", name="previousPoints", paramNum=7 },
                currentPoints={ dataType="integer", name="currentPoints", paramNum=8 },
            },
        },
        ["EVENT_DISGUISE_STATE_CHANGED"] = {
            CODE=EVENT_DISGUISE_STATE_CHANGED,
            DESCR="EVENT_DISGUISE_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                disguiseState={ dataType="integer", name="disguiseState", paramNum=3 },
            },
        },
        ["EVENT_DISPLAY_ACTIVE_COMBAT_TIP"] = {
            CODE=EVENT_DISPLAY_ACTIVE_COMBAT_TIP,
            DESCR="EVENT_DISPLAY_ACTIVE_COMBAT_TIP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                activeCombatTipId={ dataType="integer", name="activeCombatTipId", paramNum=2 },
            },
        },
        ["EVENT_DISPLAY_ANNOUNCEMENT"] = {
            CODE=EVENT_DISPLAY_ANNOUNCEMENT,
            DESCR="EVENT_DISPLAY_ANNOUNCEMENT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                title={ dataType="string", name="title", paramNum=2 },
                description={ dataType="string", name="description", paramNum=3 },
            },
        },
        ["EVENT_DISPLAY_TUTORIAL"] = {
            CODE=EVENT_DISPLAY_TUTORIAL,
            DESCR="EVENT_DISPLAY_TUTORIAL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                tutorialIndex={ dataType="luaindex", name="tutorialIndex", paramNum=2 },
            },
        },
        ["EVENT_DISPOSITION_UPDATE"] = {
            CODE=EVENT_DISPOSITION_UPDATE,
            DESCR="EVENT_DISPOSITION_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_DYEING_STATION_INTERACT_END"] = {
            CODE=EVENT_DYEING_STATION_INTERACT_END,
            DESCR="EVENT_DYEING_STATION_INTERACT_END",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_DYEING_STATION_INTERACT_START"] = {
            CODE=EVENT_DYEING_STATION_INTERACT_START,
            DESCR="EVENT_DYEING_STATION_INTERACT_START",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_EFFECTS_FULL_UPDATE"] = {
            CODE=EVENT_EFFECTS_FULL_UPDATE,
            DESCR="EVENT_EFFECTS_FULL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_EFFECT_CHANGED"] = {
            CODE=EVENT_EFFECT_CHANGED,
            DESCR="EVENT_EFFECT_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                changeType={ dataType="integer", name="changeType", paramNum=2 },
                effectSlot={ dataType="integer", name="effectSlot", paramNum=3 },
                effectName={ dataType="string", name="effectName", paramNum=4 },
                unitTag={ dataType="string", name="unitTag", paramNum=5 },
                beginTime={ dataType="number", name="beginTime", paramNum=6 },
                endTime={ dataType="number", name="endTime", paramNum=7 },
                stackCount={ dataType="integer", name="stackCount", paramNum=8 },
                iconName={ dataType="string", name="iconName", paramNum=9 },
                buffType={ dataType="string", name="buffType", paramNum=10 },
                effectType={ dataType="integer", name="effectType", paramNum=11 },
                abilityType={ dataType="integer", name="abilityType", paramNum=12 },
                statusEffectType={ dataType="integer", name="statusEffectType", paramNum=13 },
            },
        },
        ["EVENT_ENABLE_SIEGE_AIM_ABILITY"] = {
            CODE=EVENT_ENABLE_SIEGE_AIM_ABILITY,
            DESCR="EVENT_ENABLE_SIEGE_AIM_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ENABLE_SIEGE_FIRE_ABILITY"] = {
            CODE=EVENT_ENABLE_SIEGE_FIRE_ABILITY,
            DESCR="EVENT_ENABLE_SIEGE_FIRE_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ENABLE_SIEGE_PACKUP_ABILITY"] = {
            CODE=EVENT_ENABLE_SIEGE_PACKUP_ABILITY,
            DESCR="EVENT_ENABLE_SIEGE_PACKUP_ABILITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_CRAFTING_STATION_INTERACT"] = {
            CODE=EVENT_END_CRAFTING_STATION_INTERACT,
            DESCR="EVENT_END_CRAFTING_STATION_INTERACT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_FAST_TRAVEL_INTERACTION"] = {
            CODE=EVENT_END_FAST_TRAVEL_INTERACTION,
            DESCR="EVENT_END_FAST_TRAVEL_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_FAST_TRAVEL_KEEP_INTERACTION"] = {
            CODE=EVENT_END_FAST_TRAVEL_KEEP_INTERACTION,
            DESCR="EVENT_END_FAST_TRAVEL_KEEP_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_KEEP_GUILD_CLAIM_INTERACTION"] = {
            CODE=EVENT_END_KEEP_GUILD_CLAIM_INTERACTION,
            DESCR="EVENT_END_KEEP_GUILD_CLAIM_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_KEEP_GUILD_RELEASE_INTERACTION"] = {
            CODE=EVENT_END_KEEP_GUILD_RELEASE_INTERACTION,
            DESCR="EVENT_END_KEEP_GUILD_RELEASE_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_SIEGE_CONTROL"] = {
            CODE=EVENT_END_SIEGE_CONTROL,
            DESCR="EVENT_END_SIEGE_CONTROL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_END_SOUL_GEM_RESURRECTION"] = {
            CODE=EVENT_END_SOUL_GEM_RESURRECTION,
            DESCR="EVENT_END_SOUL_GEM_RESURRECTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ENTER_GROUND_TARGET_MODE"] = {
            CODE=EVENT_ENTER_GROUND_TARGET_MODE,
            DESCR="EVENT_ENTER_GROUND_TARGET_MODE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        -- updated to include Champion Points
        ["EVENT_EXPERIENCE_GAIN"] = {
            CODE=EVENT_EXPERIENCE_GAIN,
            DESCR="EVENT_EXPERIENCE_GAIN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                level={ dataType="integer", name="level", paramNum=3 },
                previousExperience={ dataType="integer", name="previousExperience", paramNum=4 },
                currentExperience={ dataType="integer", name="currentExperience", paramNum=5 },
                championPoints={ dataType="integer", name="championPoints", paramNum=6 },
            },
        },
        ["EVENT_EXPERIENCE_UPDATE"] = {
            CODE=EVENT_EXPERIENCE_UPDATE,
            DESCR="EVENT_EXPERIENCE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                currentExp={ dataType="integer", name="currentExp", paramNum=3 },
                maxExp={ dataType="integer", name="maxExp", paramNum=4 },
                reason={ dataType="integer", name="reason", paramNum=5 },
            },
        },
        ["EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED"] = {
            CODE=EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED,
            DESCR="EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                linkIndex={ dataType="luaindex", name="linkIndex", paramNum=2 },
                linkType={ dataType="integer", name="linkType", paramNum=3 },
                owningAlliance={ dataType="integer", name="owningAlliance", paramNum=4 },
                oldLinkType={ dataType="integer", name="oldLinkType", paramNum=5 },
                oldOwningAlliance={ dataType="integer", name="oldOwningAlliance", paramNum=6 },
                isLocal={ dataType="bool", name="isLocal", paramNum=7 },
            },
        },
        ["EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED"] = {
            CODE=EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED,
            DESCR="EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_FAST_TRAVEL_NETWORK_UPDATED"] = {
            CODE=EVENT_FAST_TRAVEL_NETWORK_UPDATED,
            DESCR="EVENT_FAST_TRAVEL_NETWORK_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                nodeIndex={ dataType="luaindex", name="nodeIndex", paramNum=2 },
            },
        },
        ["EVENT_FEEDBACK_REQUESTED"] = {
            CODE=EVENT_FEEDBACK_REQUESTED,
            DESCR="EVENT_FEEDBACK_REQUESTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                feedbackId={ dataType="integer", name="feedbackId", paramNum=2 },
            },
        },
        ["EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT"] = {
            CODE=EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT,
            DESCR="EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_FINESSE_RANK_CHANGED"] = {
            CODE=EVENT_FINESSE_RANK_CHANGED,
            DESCR="EVENT_FINESSE_RANK_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                rankNum={ dataType="luaindex", name="rankNum", paramNum=3 },
                name={ dataType="string", name="name", paramNum=4 },
                xpBonus={ dataType="integer", name="xpBonus", paramNum=5 },
                loot={ dataType="bool", name="loot", paramNum=6 },
            },
        },
        ["EVENT_FISHING_LURE_CLEARED"] = {
            CODE=EVENT_FISHING_LURE_CLEARED,
            DESCR="EVENT_FISHING_LURE_CLEARED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_FISHING_LURE_SET"] = {
            CODE=EVENT_FISHING_LURE_SET,
            DESCR="EVENT_FISHING_LURE_SET",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                fishingLure={ dataType="luaindex", name="fishingLure", paramNum=2 },
            },
        },
        ["EVENT_FORWARD_CAMPS_UPDATED"] = {
            CODE=EVENT_FORWARD_CAMPS_UPDATED,
            DESCR="EVENT_FORWARD_CAMPS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GAME_CAMERA_ACTIVATED"] = {
            CODE=EVENT_GAME_CAMERA_ACTIVATED,
            DESCR="EVENT_GAME_CAMERA_ACTIVATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GAME_CAMERA_DEACTIVATED"] = {
            CODE=EVENT_GAME_CAMERA_DEACTIVATED,
            DESCR="EVENT_GAME_CAMERA_DEACTIVATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GAME_CAMERA_UI_MODE_CHANGED"] = {
            CODE=EVENT_GAME_CAMERA_UI_MODE_CHANGED,
            DESCR="EVENT_GAME_CAMERA_UI_MODE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GAME_FOCUS_CHANGED"] = {
            CODE=EVENT_GAME_FOCUS_CHANGED,
            DESCR="EVENT_GAME_FOCUS_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                hasFocus={ dataType="bool", name="hasFocus", paramNum=2 },
            },
        },
        ["EVENT_GRAVEYARD_USAGE_FAILURE"] = {
            CODE=EVENT_GRAVEYARD_USAGE_FAILURE,
            DESCR="EVENT_GRAVEYARD_USAGE_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GROUPING_TOOLS_STATUS_UPDATE"] = {
            CODE=EVENT_GROUPING_TOOLS_STATUS_UPDATE,
            DESCR="EVENT_GROUPING_TOOLS_STATUS_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inQueue={ dataType="bool", name="inQueue", paramNum=2 },
            },
        },
        ["EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED"] = {
            CODE=EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED,
            DESCR="EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GROUP_DISBANDED"] = {
            CODE=EVENT_GROUP_DISBANDED,
            DESCR="EVENT_GROUP_DISBANDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GROUP_INVITE_RECEIVED"] = {
            CODE=EVENT_GROUP_INVITE_RECEIVED,
            DESCR="EVENT_GROUP_INVITE_RECEIVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inviterName={ dataType="string", name="inviterName", paramNum=2 },
            },
        },
        ["EVENT_GROUP_INVITE_REMOVED"] = {
            CODE=EVENT_GROUP_INVITE_REMOVED,
            DESCR="EVENT_GROUP_INVITE_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GROUP_INVITE_RESPONSE"] = {
            CODE=EVENT_GROUP_INVITE_RESPONSE,
            DESCR="EVENT_GROUP_INVITE_RESPONSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inviterName={ dataType="string", name="inviterName", paramNum=2 },
                response={ dataType="integer", name="response", paramNum=3 },
            },
        },
        ["EVENT_GROUP_MEMBER_CONNECTED_STATUS"] = {
            CODE=EVENT_GROUP_MEMBER_CONNECTED_STATUS,
            DESCR="EVENT_GROUP_MEMBER_CONNECTED_STATUS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                isOnline={ dataType="bool", name="isOnline", paramNum=3 },
            },
        },
        ["EVENT_GROUP_MEMBER_IN_REMOTE_REGION"] = {
            CODE=EVENT_GROUP_MEMBER_IN_REMOTE_REGION,
            DESCR="EVENT_GROUP_MEMBER_IN_REMOTE_REGION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                isInRemoteRegion={ dataType="bool", name="isInRemoteRegion", paramNum=3 },
            },
        },
        ["EVENT_GROUP_MEMBER_JOINED"] = {
            CODE=EVENT_GROUP_MEMBER_JOINED,
            DESCR="EVENT_GROUP_MEMBER_JOINED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                memberName={ dataType="string", name="memberName", paramNum=2 },
            },
        },
        ["EVENT_GROUP_MEMBER_LEFT"] = {
            CODE=EVENT_GROUP_MEMBER_LEFT,
            DESCR="EVENT_GROUP_MEMBER_LEFT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                memberName={ dataType="string", name="memberName", paramNum=2 },
                reason={ dataType="integer", name="reason", paramNum=3 },
                wasLocalPlayer={ dataType="bool", name="wasLocalPlayer", paramNum=4 },
            },
        },
        ["EVENT_GROUP_MEMBER_ROLES_CHANGED"] = {
            CODE=EVENT_GROUP_MEMBER_ROLES_CHANGED,
            DESCR="EVENT_GROUP_MEMBER_ROLES_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                dps={ dataType="bool", name="dps", paramNum=3 },
                healer={ dataType="bool", name="healer", paramNum=4 },
                tank={ dataType="bool", name="tank", paramNum=5 },
            },
        },
        ["EVENT_GROUP_NOTIFICATION_MESSAGE"] = {
            CODE=EVENT_GROUP_NOTIFICATION_MESSAGE,
            DESCR="EVENT_GROUP_NOTIFICATION_MESSAGE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                messageId={ dataType="integer", name="messageId", paramNum=2 },
            },
        },
        ["EVENT_GROUP_SUPPORT_RANGE_UPDATE"] = {
            CODE=EVENT_GROUP_SUPPORT_RANGE_UPDATE,
            DESCR="EVENT_GROUP_SUPPORT_RANGE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                status={ dataType="bool", name="status", paramNum=3 },
            },
        },
        ["EVENT_GROUP_TYPE_CHANGED"] = {
            CODE=EVENT_GROUP_TYPE_CHANGED,
            DESCR="EVENT_GROUP_TYPE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                largeGroup={ dataType="bool", name="largeGroup", paramNum=2 },
            },
        },
        ["EVENT_GUEST_CAMPAIGN_CHANGED"] = {
            CODE=EVENT_GUEST_CAMPAIGN_CHANGED,
            DESCR="EVENT_GUEST_CAMPAIGN_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newGuestCampaignId={ dataType="integer", name="newGuestCampaignId", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANKED_MONEY_UPDATE"] = {
            CODE=EVENT_GUILD_BANKED_MONEY_UPDATE,
            DESCR="EVENT_GUILD_BANKED_MONEY_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newBankedMoney={ dataType="integer", name="newBankedMoney", paramNum=2 },
                oldBankedMoney={ dataType="integer", name="oldBankedMoney", paramNum=3 },
            },
        },
        ["EVENT_GUILD_BANK_DESELECTED"] = {
            CODE=EVENT_GUILD_BANK_DESELECTED,
            DESCR="EVENT_GUILD_BANK_DESELECTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_BANK_ITEMS_READY"] = {
            CODE=EVENT_GUILD_BANK_ITEMS_READY,
            DESCR="EVENT_GUILD_BANK_ITEMS_READY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_BANK_ITEM_ADDED"] = {
            CODE=EVENT_GUILD_BANK_ITEM_ADDED,
            DESCR="EVENT_GUILD_BANK_ITEM_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotId={ dataType="integer", name="slotId", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANK_ITEM_REMOVED"] = {
            CODE=EVENT_GUILD_BANK_ITEM_REMOVED,
            DESCR="EVENT_GUILD_BANK_ITEM_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotId={ dataType="integer", name="slotId", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANK_OPEN_ERROR"] = {
            CODE=EVENT_GUILD_BANK_OPEN_ERROR,
            DESCR="EVENT_GUILD_BANK_OPEN_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANK_SELECTED"] = {
            CODE=EVENT_GUILD_BANK_SELECTED,
            DESCR="EVENT_GUILD_BANK_SELECTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                guildId={ dataType="integer", name="guildId", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANK_TRANSFER_ERROR"] = {
            CODE=EVENT_GUILD_BANK_TRANSFER_ERROR,
            DESCR="EVENT_GUILD_BANK_TRANSFER_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_GUILD_BANK_UPDATED_QUANTITY"] = {
            CODE=EVENT_GUILD_BANK_UPDATED_QUANTITY,
            DESCR="EVENT_GUILD_BANK_UPDATED_QUANTITY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotId={ dataType="integer", name="slotId", paramNum=2 },
            },
        },
        ["EVENT_GUILD_KIOSK_CONSIDER_BID_START"] = {
            CODE=EVENT_GUILD_KIOSK_CONSIDER_BID_START,
            DESCR="EVENT_GUILD_KIOSK_CONSIDER_BID_START",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_KIOSK_CONSIDER_BID_STOP"] = {
            CODE=EVENT_GUILD_KIOSK_CONSIDER_BID_STOP,
            DESCR="EVENT_GUILD_KIOSK_CONSIDER_BID_STOP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_START"] = {
            CODE=EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_START,
            DESCR="EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_START",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_STOP"] = {
            CODE=EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_STOP,
            DESCR="EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_STOP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_GUILD_KIOSK_ERROR"] = {
            CODE=EVENT_GUILD_KIOSK_ERROR,
            DESCR="EVENT_GUILD_KIOSK_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_HELP_INITIALIZED"] = {
            CODE=EVENT_HELP_INITIALIZED,
            DESCR="EVENT_HELP_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HELP_SEARCH_RESULTS_READY"] = {
            CODE=EVENT_HELP_SEARCH_RESULTS_READY,
            DESCR="EVENT_HELP_SEARCH_RESULTS_READY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HERALDRY_CUSTOMIZATION_END"] = {
            CODE=EVENT_HERALDRY_CUSTOMIZATION_END,
            DESCR="EVENT_HERALDRY_CUSTOMIZATION_END",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HERALDRY_CUSTOMIZATION_START"] = {
            CODE=EVENT_HERALDRY_CUSTOMIZATION_START,
            DESCR="EVENT_HERALDRY_CUSTOMIZATION_START",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HERALDRY_FUNDS_UPDATED"] = {
            CODE=EVENT_HERALDRY_FUNDS_UPDATED,
            DESCR="EVENT_HERALDRY_FUNDS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HERALDRY_SAVED"] = {
            CODE=EVENT_HERALDRY_SAVED,
            DESCR="EVENT_HERALDRY_SAVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HIDE_BOOK"] = {
            CODE=EVENT_HIDE_BOOK,
            DESCR="EVENT_HIDE_BOOK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HIDE_OBJECTIVE_STATUS"] = {
            CODE=EVENT_HIDE_OBJECTIVE_STATUS,
            DESCR="EVENT_HIDE_OBJECTIVE_STATUS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_HOT_BAR_RESULT"] = {
            CODE=EVENT_HOT_BAR_RESULT,
            DESCR="EVENT_HOT_BAR_RESULT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_IMPACTFUL_HIT"] = {
            CODE=EVENT_IMPACTFUL_HIT,
            DESCR="EVENT_IMPACTFUL_HIT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_IMPERIAL_CITY_CONTROL_CHANGE_NOTIFICATION"] = {
            CODE=EVENT_IMPERIAL_CITY_CONTROL_CHANGE_NOTIFICATION,
            DESCR="EVENT_IMPERIAL_CITY_CONTROL_CHANGE_NOTIFICATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                oldAlliance={ dataType="integer", name="oldAlliance", paramNum=3 },
                newAlliance={ dataType="integer", name="newAlliance", paramNum=4 },
            },
        },
        ["EVENT_INSTANCE_KICK_TIME_UPDATE"] = {
            CODE=EVENT_INSTANCE_KICK_TIME_UPDATE,
            DESCR="EVENT_INSTANCE_KICK_TIME_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                timeRemainingMs={ dataType="integer", name="timeRemainingMs", paramNum=2 },
            },
        },
        ["EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK"] = {
            CODE=EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK,
            DESCR="EVENT_INTERACTABLE_IMPOSSIBLE_TO_PICK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                interactableName={ dataType="string", name="interactableName", paramNum=2 },
            },
        },
        ["EVENT_INTERACTABLE_LOCKED"] = {
            CODE=EVENT_INTERACTABLE_LOCKED,
            DESCR="EVENT_INTERACTABLE_LOCKED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                interactableName={ dataType="string", name="interactableName", paramNum=2 },
            },
        },
        ["EVENT_INTERACT_BUSY"] = {
            CODE=EVENT_INTERACT_BUSY,
            DESCR="EVENT_INTERACT_BUSY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_INTERFACE_SETTING_CHANGED"] = {
            CODE=EVENT_INTERFACE_SETTING_CHANGED,
            DESCR="EVENT_INTERFACE_SETTING_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                system={ dataType="integer", name="system", paramNum=2 },
                settingId={ dataType="integer", name="settingId", paramNum=3 },
            },
        },
        ["EVENT_INVENTORY_BOUGHT_BAG_SPACE"] = {
            CODE=EVENT_INVENTORY_BOUGHT_BAG_SPACE,
            DESCR="EVENT_INVENTORY_BOUGHT_BAG_SPACE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                numberOfSlots={ dataType="integer", name="numberOfSlots", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_BOUGHT_BANK_SPACE"] = {
            CODE=EVENT_INVENTORY_BOUGHT_BANK_SPACE,
            DESCR="EVENT_INVENTORY_BOUGHT_BANK_SPACE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                numberOfSlots={ dataType="integer", name="numberOfSlots", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_BUY_BAG_SPACE"] = {
            CODE=EVENT_INVENTORY_BUY_BAG_SPACE,
            DESCR="EVENT_INVENTORY_BUY_BAG_SPACE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                cost={ dataType="integer", name="cost", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_BUY_BANK_SPACE"] = {
            CODE=EVENT_INVENTORY_BUY_BANK_SPACE,
            DESCR="EVENT_INVENTORY_BUY_BANK_SPACE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                cost={ dataType="integer", name="cost", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_CLOSE_BUY_SPACE"] = {
            CODE=EVENT_INVENTORY_CLOSE_BUY_SPACE,
            DESCR="EVENT_INVENTORY_CLOSE_BUY_SPACE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_INVENTORY_FULL_UPDATE"] = {
            CODE=EVENT_INVENTORY_FULL_UPDATE,
            DESCR="EVENT_INVENTORY_FULL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_INVENTORY_IS_FULL"] = {
            CODE=EVENT_INVENTORY_IS_FULL,
            DESCR="EVENT_INVENTORY_IS_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                numSlotsRequested={ dataType="integer", name="numSlotsRequested", paramNum=2 },
                numSlotsFree={ dataType="integer", name="numSlotsFree", paramNum=3 },
            },
        },
        ["EVENT_INVENTORY_ITEM_DESTROYED"] = {
            CODE=EVENT_INVENTORY_ITEM_DESTROYED,
            DESCR="EVENT_INVENTORY_ITEM_DESTROYED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_ITEM_USED"] = {
            CODE=EVENT_INVENTORY_ITEM_USED,
            DESCR="EVENT_INVENTORY_ITEM_USED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=2 },
            },
        },
        ["EVENT_INVENTORY_SINGLE_SLOT_UPDATE"] = {
            CODE=EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            DESCR="EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotId={ dataType="integer", name="slotId", paramNum=3 },
                isNewItem={ dataType="bool", name="isNewItem", paramNum=4 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=5 },
                updateReason={ dataType="integer", name="updateReason", paramNum=6 },
            },
        },
        ["EVENT_INVENTORY_SLOT_LOCKED"] = {
            CODE=EVENT_INVENTORY_SLOT_LOCKED,
            DESCR="EVENT_INVENTORY_SLOT_LOCKED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotId={ dataType="integer", name="slotId", paramNum=3 },
            },
        },
        ["EVENT_INVENTORY_SLOT_UNLOCKED"] = {
            CODE=EVENT_INVENTORY_SLOT_UNLOCKED,
            DESCR="EVENT_INVENTORY_SLOT_UNLOCKED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotId={ dataType="integer", name="slotId", paramNum=3 },
            },
        },
        ["EVENT_ITEM_ON_COOLDOWN"] = {
            CODE=EVENT_ITEM_ON_COOLDOWN,
            DESCR="EVENT_ITEM_ON_COOLDOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ITEM_REPAIR_FAILURE"] = {
            CODE=EVENT_ITEM_REPAIR_FAILURE,
            DESCR="EVENT_ITEM_REPAIR_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_ITEM_SLOT_CHANGED"] = {
            CODE=EVENT_ITEM_SLOT_CHANGED,
            DESCR="EVENT_ITEM_SLOT_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=2 },
            },
        },
        ["EVENT_JUMP_FAILED"] = {
            CODE=EVENT_JUMP_FAILED,
            DESCR="EVENT_JUMP_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_JUSTICE_BOUNTY_ADDED"] = {
            CODE=EVENT_JUSTICE_BOUNTY_ADDED,
            DESCR="EVENT_JUSTICE_BOUNTY_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bountyAmount={ dataType="integer", name="bountyAmount", paramNum=2 },
                zoneName={ dataType="string", name="zoneName", paramNum=3 },
            },
        },
        ["EVENT_JUSTICE_FENCE_UPDATE"] = {
            CODE=EVENT_JUSTICE_FENCE_UPDATE,
            DESCR="EVENT_JUSTICE_FENCE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                sellsUsed={ dataType="integer", name="sellsUsed", paramNum=2 },
                laundersUsed={ dataType="string", name="laundersUsed", paramNum=3 },
            },
        },
        ["EVENT_KEEPS_INITIALIZED"] = {
            CODE=EVENT_KEEPS_INITIALIZED,
            DESCR="EVENT_KEEPS_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_KEEP_ALLIANCE_OWNER_CHANGED"] = {
            CODE=EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
            DESCR="EVENT_KEEP_ALLIANCE_OWNER_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=3 },
                owningAlliance={ dataType="integer", name="owningAlliance", paramNum=4 },
            },
        },
        ["EVENT_KEEP_END_INTERACTION"] = {
            CODE=EVENT_KEEP_END_INTERACTION,
            DESCR="EVENT_KEEP_END_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_KEEP_GATE_STATE_CHANGED"] = {
            CODE=EVENT_KEEP_GATE_STATE_CHANGED,
            DESCR="EVENT_KEEP_GATE_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                open={ dataType="bool", name="open", paramNum=3 },
            },
        },
        ["EVENT_KEEP_GUILD_CLAIM_UPDATE"] = {
            CODE=EVENT_KEEP_GUILD_CLAIM_UPDATE,
            DESCR="EVENT_KEEP_GUILD_CLAIM_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=3 },
            },
        },
        ["EVENT_KEEP_INITIALIZED"] = {
            CODE=EVENT_KEEP_INITIALIZED,
            DESCR="EVENT_KEEP_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=3 },
            },
        },
        ["EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION"] = {
            CODE=EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION,
            DESCR="EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                campaignId={ dataType="integer", name="campaignId", paramNum=2 },
                keepId={ dataType="integer", name="keepId", paramNum=3 },
                oldOwner={ dataType="integer", name="oldOwner", paramNum=4 },
                newOwner={ dataType="integer", name="newOwner", paramNum=5 },
            },
        },
        ["EVENT_KEEP_RESOURCE_UPDATE"] = {
            CODE=EVENT_KEEP_RESOURCE_UPDATE,
            DESCR="EVENT_KEEP_RESOURCE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
            },
        },
        ["EVENT_KEEP_START_INTERACTION"] = {
            CODE=EVENT_KEEP_START_INTERACTION,
            DESCR="EVENT_KEEP_START_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_KEEP_UNDER_ATTACK_CHANGED"] = {
            CODE=EVENT_KEEP_UNDER_ATTACK_CHANGED,
            DESCR="EVENT_KEEP_UNDER_ATTACK_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=3 },
                underAttack={ dataType="bool", name="underAttack", paramNum=4 },
            },
        },
        ["EVENT_KILL_LOCATIONS_UPDATED"] = {
            CODE=EVENT_KILL_LOCATIONS_UPDATED,
            DESCR="EVENT_KILL_LOCATIONS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LEADER_UPDATE"] = {
            CODE=EVENT_LEADER_UPDATE,
            DESCR="EVENT_LEADER_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                leaderTag={ dataType="string", name="leaderTag", paramNum=2 },
            },
        },
        ["EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE"] = {
            CODE=EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE,
            DESCR="EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                response={ dataType="integer", name="response", paramNum=2 },
            },
        },
        ["EVENT_LEAVE_RAM_ESCORT"] = {
            CODE=EVENT_LEAVE_RAM_ESCORT,
            DESCR="EVENT_LEAVE_RAM_ESCORT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LEVEL_UPDATE"] = {
            CODE=EVENT_LEVEL_UPDATE,
            DESCR="EVENT_LEVEL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                level={ dataType="integer", name="level", paramNum=3 },
            },
        },
        ["EVENT_LINKED_WORLD_POSITION_CHANGED"] = {
            CODE=EVENT_LINKED_WORLD_POSITION_CHANGED,
            DESCR="EVENT_LINKED_WORLD_POSITION_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LOCKPICK_BROKE"] = {
            CODE=EVENT_LOCKPICK_BROKE,
            DESCR="EVENT_LOCKPICK_BROKE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inactivityLengthMs={ dataType="integer", name="inactivityLengthMs", paramNum=2 },
            },
        },
        ["EVENT_LOCKPICK_FAILED"] = {
            CODE=EVENT_LOCKPICK_FAILED,
            DESCR="EVENT_LOCKPICK_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LOCKPICK_SUCCESS"] = {
            CODE=EVENT_LOCKPICK_SUCCESS,
            DESCR="EVENT_LOCKPICK_SUCCESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LOGOUT_DEFERRED"] = {
            CODE=EVENT_LOGOUT_DEFERRED,
            DESCR="EVENT_LOGOUT_DEFERRED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                deferMilliseconds={ dataType="integer", name="deferMilliseconds", paramNum=2 },
                quitRequested={ dataType="bool", name="quitRequested", paramNum=3 },
            },
        },
        ["EVENT_LOGOUT_DISALLOWED"] = {
            CODE=EVENT_LOGOUT_DISALLOWED,
            DESCR="EVENT_LOGOUT_DISALLOWED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                quitRequested={ dataType="bool", name="quitRequested", paramNum=2 },
            },
        },
        ["EVENT_LOOT_CLOSED"] = {
            CODE=EVENT_LOOT_CLOSED,
            DESCR="EVENT_LOOT_CLOSED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LOOT_ITEM_FAILED"] = {
            CODE=EVENT_LOOT_ITEM_FAILED,
            DESCR="EVENT_LOOT_ITEM_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                itemName={ dataType="string", name="itemName", paramNum=3 },
            },
        },
        ["EVENT_LOOT_RECEIVED"] = {
            CODE=EVENT_LOOT_RECEIVED,
            DESCR="EVENT_LOOT_RECEIVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                receivedBy={ dataType="string", name="receivedBy", paramNum=2 },
                itemName={ dataType="string", name="itemName", paramNum=3 },
                quantity={ dataType="integer", name="quantity", paramNum=4 },
                itemSound={ dataType="integer", name="itemSound", paramNum=5 },
                lootType={ dataType="integer", name="lootType", paramNum=6 },
                self={ dataType="bool", name="self", paramNum=7 },
            },
        },
        ["EVENT_LOOT_UPDATED"] = {
            CODE=EVENT_LOOT_UPDATED,
            DESCR="EVENT_LOOT_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_LORE_BOOK_ALREADY_KNOWN"] = {
            CODE=EVENT_LORE_BOOK_ALREADY_KNOWN,
            DESCR="EVENT_LORE_BOOK_ALREADY_KNOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bookTitle={ dataType="string", name="bookTitle", paramNum=2 },
            },
        },
        ["EVENT_LORE_BOOK_LEARNED"] = {
            CODE=EVENT_LORE_BOOK_LEARNED,
            DESCR="EVENT_LORE_BOOK_LEARNED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=2 },
                collectionIndex={ dataType="luaindex", name="collectionIndex", paramNum=3 },
                bookIndex={ dataType="luaindex", name="bookIndex", paramNum=4 },
                guildIndex={ dataType="luaindex", name="guildIndex", paramNum=5 },
            },
        },
        ["EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE"] = {
            CODE=EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE,
            DESCR="EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=2 },
                collectionIndex={ dataType="luaindex", name="collectionIndex", paramNum=3 },
                bookIndex={ dataType="luaindex", name="bookIndex", paramNum=4 },
                guildIndex={ dataType="luaindex", name="guildIndex", paramNum=5 },
                skillType={ dataType="integer", name="skillType", paramNum=6 },
                skillIndex={ dataType="luaindex", name="skillIndex", paramNum=7 },
                rank={ dataType="luaindex", name="rank", paramNum=8 },
                previousXP={ dataType="integer", name="previousXP", paramNum=9 },
                currentXP={ dataType="integer", name="currentXP", paramNum=10 },
            },
        },
        ["EVENT_LORE_COLLECTION_COMPLETED"] = {
            CODE=EVENT_LORE_COLLECTION_COMPLETED,
            DESCR="EVENT_LORE_COLLECTION_COMPLETED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=2 },
                collectionIndex={ dataType="luaindex", name="collectionIndex", paramNum=3 },
                guildIndex={ dataType="luaindex", name="guildIndex", paramNum=4 },
            },
        },
        ["EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE"] = {
            CODE=EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE,
            DESCR="EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=2 },
                collectionIndex={ dataType="luaindex", name="collectionIndex", paramNum=3 },
                guildIndex={ dataType="luaindex", name="guildIndex", paramNum=4 },
                skillType={ dataType="integer", name="skillType", paramNum=5 },
                skillIndex={ dataType="luaindex", name="skillIndex", paramNum=6 },
                rank={ dataType="luaindex", name="rank", paramNum=7 },
                previousXP={ dataType="integer", name="previousXP", paramNum=8 },
                currentXP={ dataType="integer", name="currentXP", paramNum=9 },
            },
        },
        ["EVENT_LORE_LIBRARY_INITIALIZED"] = {
            CODE=EVENT_LORE_LIBRARY_INITIALIZED,
            DESCR="EVENT_LORE_LIBRARY_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MAIL_ATTACHED_MONEY_CHANGED"] = {
            CODE=EVENT_MAIL_ATTACHED_MONEY_CHANGED,
            DESCR="EVENT_MAIL_ATTACHED_MONEY_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                moneyAmount={ dataType="integer", name="moneyAmount", paramNum=2 },
            },
        },
        ["EVENT_MAIL_ATTACHMENT_ADDED"] = {
            CODE=EVENT_MAIL_ATTACHMENT_ADDED,
            DESCR="EVENT_MAIL_ATTACHMENT_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                attachmentSlot={ dataType="luaindex", name="attachmentSlot", paramNum=2 },
            },
        },
        ["EVENT_MAIL_ATTACHMENT_REMOVED"] = {
            CODE=EVENT_MAIL_ATTACHMENT_REMOVED,
            DESCR="EVENT_MAIL_ATTACHMENT_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                attachmentSlot={ dataType="luaindex", name="attachmentSlot", paramNum=2 },
            },
        },
        ["EVENT_MAIL_CLOSE_MAILBOX"] = {
            CODE=EVENT_MAIL_CLOSE_MAILBOX,
            DESCR="EVENT_MAIL_CLOSE_MAILBOX",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MAIL_COD_CHANGED"] = {
            CODE=EVENT_MAIL_COD_CHANGED,
            DESCR="EVENT_MAIL_COD_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                codAmount={ dataType="integer", name="codAmount", paramNum=2 },
            },
        },
        ["EVENT_MAIL_INBOX_UPDATE"] = {
            CODE=EVENT_MAIL_INBOX_UPDATE,
            DESCR="EVENT_MAIL_INBOX_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MAIL_NUM_UNREAD_CHANGED"] = {
            CODE=EVENT_MAIL_NUM_UNREAD_CHANGED,
            DESCR="EVENT_MAIL_NUM_UNREAD_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                numUnread={ dataType="integer", name="numUnread", paramNum=2 },
            },
        },
        ["EVENT_MAIL_OPEN_MAILBOX"] = {
            CODE=EVENT_MAIL_OPEN_MAILBOX,
            DESCR="EVENT_MAIL_OPEN_MAILBOX",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MAIL_READABLE"] = {
            CODE=EVENT_MAIL_READABLE,
            DESCR="EVENT_MAIL_READABLE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mailId={ dataType="id64", name="mailId", paramNum=2 },
            },
        },
        ["EVENT_MAIL_REMOVED"] = {
            CODE=EVENT_MAIL_REMOVED,
            DESCR="EVENT_MAIL_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mailId={ dataType="id64", name="mailId", paramNum=2 },
            },
        },
        ["EVENT_MAIL_SEND_FAILED"] = {
            CODE=EVENT_MAIL_SEND_FAILED,
            DESCR="EVENT_MAIL_SEND_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_MAIL_SEND_SUCCESS"] = {
            CODE=EVENT_MAIL_SEND_SUCCESS,
            DESCR="EVENT_MAIL_SEND_SUCCESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS"] = {
            CODE=EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS,
            DESCR="EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mailId={ dataType="id64", name="mailId", paramNum=2 },
            },
        },
        ["EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS"] = {
            CODE=EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS,
            DESCR="EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mailId={ dataType="id64", name="mailId", paramNum=2 },
            },
        },
        ["EVENT_MAP_PING"] = {
            CODE=EVENT_MAP_PING,
            DESCR="EVENT_MAP_PING",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                pingEventType={ dataType="integer", name="pingEventType", paramNum=2 },
                pingType={ dataType="integer", name="pingType", paramNum=3 },
                pingTag={ dataType="string", name="pingTag", paramNum=4 },
                offsetX={ dataType="number", name="offsetX", paramNum=5 },
                offsetY={ dataType="number", name="offsetY", paramNum=6 },
            },
        },
        ["EVENT_MEDAL_AWARDED"] = {
            CODE=EVENT_MEDAL_AWARDED,
            DESCR="EVENT_MEDAL_AWARDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                name={ dataType="string", name="name", paramNum=2 },
                texture={ dataType="string", name="texture", paramNum=3 },
                condition={ dataType="string", name="condition", paramNum=4 },
            },
        },
        ["EVENT_MISSING_LURE"] = {
            CODE=EVENT_MISSING_LURE,
            DESCR="EVENT_MISSING_LURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MONEY_UPDATE"] = {
            CODE=EVENT_MONEY_UPDATE,
            DESCR="EVENT_MONEY_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newMoney={ dataType="integer", name="newMoney", paramNum=2 },
                oldMoney={ dataType="integer", name="oldMoney", paramNum=3 },
                reason={ dataType="integer", name="reason", paramNum=4 },
            },
        },
        ["EVENT_MOUNTED_STATE_CHANGED"] = {
            CODE=EVENT_MOUNTED_STATE_CHANGED,
            DESCR="EVENT_MOUNTED_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mounted={ dataType="bool", name="mounted", paramNum=2 },
            },
        },
        ["EVENT_MOUNTS_FULL_UPDATE"] = {
            CODE=EVENT_MOUNTS_FULL_UPDATE,
            DESCR="EVENT_MOUNTS_FULL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MOUNT_ADDED_TO_STABLE"] = {
            CODE=EVENT_MOUNT_ADDED_TO_STABLE,
            DESCR="EVENT_MOUNT_ADDED_TO_STABLE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_MOUNT_FAILURE"] = {
            CODE=EVENT_MOUNT_FAILURE,
            DESCR="EVENT_MOUNT_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                arg1={ dataType="integer", name="arg1", paramNum=3 },
            },
        },
        ["EVENT_MOUNT_UPDATE"] = {
            CODE=EVENT_MOUNT_UPDATE,
            DESCR="EVENT_MOUNT_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                mountIndex={ dataType="luaindex", name="mountIndex", paramNum=2 },
            },
        },
        ["EVENT_MOUSE_REQUEST_ABANDON_QUEST"] = {
            CODE=EVENT_MOUSE_REQUEST_ABANDON_QUEST,
            DESCR="EVENT_MOUSE_REQUEST_ABANDON_QUEST",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                name={ dataType="string", name="name", paramNum=3 },
            },
        },
        ["EVENT_MOUSE_REQUEST_DESTROY_ITEM"] = {
            CODE=EVENT_MOUSE_REQUEST_DESTROY_ITEM,
            DESCR="EVENT_MOUSE_REQUEST_DESTROY_ITEM",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotIndex={ dataType="integer", name="slotIndex", paramNum=3 },
                itemCount={ dataType="integer", name="itemCount", paramNum=4 },
                name={ dataType="string", name="name", paramNum=5 },
                needsConfirm={ dataType="bool", name="needsConfirm", paramNum=6 },
            },
        },
        ["EVENT_MOUSE_REQUEST_DESTROY_ITEM_FAILED"] = {
            CODE=EVENT_MOUSE_REQUEST_DESTROY_ITEM_FAILED,
            DESCR="EVENT_MOUSE_REQUEST_DESTROY_ITEM_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotIndex={ dataType="integer", name="slotIndex", paramNum=3 },
                itemCount={ dataType="integer", name="itemCount", paramNum=4 },
                name={ dataType="string", name="name", paramNum=5 },
                reason={ dataType="integer", name="reason", paramNum=6 },
            },
        },
        ["EVENT_NEW_MOVEMENT_IN_UI_MODE"] = {
            CODE=EVENT_NEW_MOVEMENT_IN_UI_MODE,
            DESCR="EVENT_NEW_MOVEMENT_IN_UI_MODE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_NON_COMBAT_BONUS_CHANGED"] = {
            CODE=EVENT_NON_COMBAT_BONUS_CHANGED,
            DESCR="EVENT_NON_COMBAT_BONUS_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                nonCombatBonus={ dataType="integer", name="nonCombatBonus", paramNum=2 },
                oldValue={ dataType="integer", name="oldValue", paramNum=3 },
                newValue={ dataType="integer", name="newValue", paramNum=4 },
            },
        },
        ["EVENT_NOT_ENOUGH_MONEY"] = {
            CODE=EVENT_NOT_ENOUGH_MONEY,
            DESCR="EVENT_NOT_ENOUGH_MONEY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_NO_INTERACT_TARGET"] = {
            CODE=EVENT_NO_INTERACT_TARGET,
            DESCR="EVENT_NO_INTERACT_TARGET",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_OBJECTIVES_UPDATED"] = {
            CODE=EVENT_OBJECTIVES_UPDATED,
            DESCR="EVENT_OBJECTIVES_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_OBJECTIVE_COMPLETED"] = {
            CODE=EVENT_OBJECTIVE_COMPLETED,
            DESCR="EVENT_OBJECTIVE_COMPLETED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                zoneIndex={ dataType="luaindex", name="zoneIndex", paramNum=2 },
                poiIndex={ dataType="luaindex", name="poiIndex", paramNum=3 },
                level={ dataType="integer", name="level", paramNum=4 },
                previousExperience={ dataType="integer", name="previousExperience", paramNum=5 },
                currentExperience={ dataType="integer", name="currentExperience", paramNum=6 },
                rank={ dataType="integer", name="rank", paramNum=7 },
                previousPoints={ dataType="integer", name="previousPoints", paramNum=8 },
                currentPoints={ dataType="integer", name="currentPoints", paramNum=9 },
            },
        },
        ["EVENT_OBJECTIVE_CONTROL_STATE"] = {
            CODE=EVENT_OBJECTIVE_CONTROL_STATE,
            DESCR="EVENT_OBJECTIVE_CONTROL_STATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                objectiveKeepId={ dataType="integer", name="objectiveKeepId", paramNum=2 },
                objectiveObjectiveId={ dataType="integer", name="objectiveObjectiveId", paramNum=3 },
                battlegroundContext={ dataType="integer", name="battlegroundContext", paramNum=4 },
                objectiveName={ dataType="string", name="objectiveName", paramNum=5 },
                objectiveType={ dataType="integer", name="objectiveType", paramNum=6 },
                objectiveControlEvent={ dataType="integer", name="objectiveControlEvent", paramNum=7 },
                objectiveControlState={ dataType="integer", name="objectiveControlState", paramNum=8 },
                objectiveParam1={ dataType="integer", name="objectiveParam1", paramNum=9 },
                objectiveParam2={ dataType="integer", name="objectiveParam2", paramNum=10 },
            },
        },
        ["EVENT_OPEN_BANK"] = {
            CODE=EVENT_OPEN_BANK,
            DESCR="EVENT_OPEN_BANK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_OPEN_GUILD_BANK"] = {
            CODE=EVENT_OPEN_GUILD_BANK,
            DESCR="EVENT_OPEN_GUILD_BANK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_OPEN_STORE"] = {
            CODE=EVENT_OPEN_STORE,
            DESCR="EVENT_OPEN_STORE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_OPEN_TRADING_HOUSE"] = {
            CODE=EVENT_OPEN_TRADING_HOUSE,
            DESCR="EVENT_OPEN_TRADING_HOUSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_ACTIVATED"] = {
            CODE=EVENT_PLAYER_ACTIVATED,
            DESCR="EVENT_PLAYER_ACTIVATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_ALIVE"] = {
            CODE=EVENT_PLAYER_ALIVE,
            DESCR="EVENT_PLAYER_ALIVE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_COMBAT_STATE"] = {
            CODE=EVENT_PLAYER_COMBAT_STATE,
            DESCR="EVENT_PLAYER_COMBAT_STATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inCombat={ dataType="bool", name="inCombat", paramNum=2 },
            },
        },
        ["EVENT_PLAYER_DEACTIVATED"] = {
            CODE=EVENT_PLAYER_DEACTIVATED,
            DESCR="EVENT_PLAYER_DEACTIVATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_DEAD"] = {
            CODE=EVENT_PLAYER_DEAD,
            DESCR="EVENT_PLAYER_DEAD",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_DEATH_INFO_UPDATE"] = {
            CODE=EVENT_PLAYER_DEATH_INFO_UPDATE,
            DESCR="EVENT_PLAYER_DEATH_INFO_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_DEATH_REQUEST_FAILURE"] = {
            CODE=EVENT_PLAYER_DEATH_REQUEST_FAILURE,
            DESCR="EVENT_PLAYER_DEATH_REQUEST_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLAYER_IN_PIN_AREA_CHANGED"] = {
            CODE=EVENT_PLAYER_IN_PIN_AREA_CHANGED,
            DESCR="EVENT_PLAYER_IN_PIN_AREA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                pinType={ dataType="integer", name="pinType", paramNum=2 },
                param1={ dataType="integer", name="param1", paramNum=3 },
                param2={ dataType="integer", name="param2", paramNum=4 },
                param3={ dataType="integer", name="param3", paramNum=5 },
                playerIsInside={ dataType="bool", name="playerIsInside", paramNum=6 },
            },
        },
        ["EVENT_PLAYER_TITLES_UPDATE"] = {
            CODE=EVENT_PLAYER_TITLES_UPDATE,
            DESCR="EVENT_PLAYER_TITLES_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLEDGE_OF_MARA_OFFER"] = {
            CODE=EVENT_PLEDGE_OF_MARA_OFFER,
            DESCR="EVENT_PLEDGE_OF_MARA_OFFER",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                targetName={ dataType="string", name="targetName", paramNum=2 },
            },
        },
        ["EVENT_PLEDGE_OF_MARA_OFFER_REMOVED"] = {
            CODE=EVENT_PLEDGE_OF_MARA_OFFER_REMOVED,
            DESCR="EVENT_PLEDGE_OF_MARA_OFFER_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_PLEDGE_OF_MARA_RESULT"] = {
            CODE=EVENT_PLEDGE_OF_MARA_RESULT,
            DESCR="EVENT_PLEDGE_OF_MARA_RESULT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                targetName={ dataType="string", name="targetName", paramNum=3 },
            },
        },
        ["EVENT_POIS_INITIALIZED"] = {
            CODE=EVENT_POIS_INITIALIZED,
            DESCR="EVENT_POIS_INITIALIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_POI_DISCOVERED"] = {
            CODE=EVENT_POI_DISCOVERED,
            DESCR="EVENT_POI_DISCOVERED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                zoneIndex={ dataType="luaindex", name="zoneIndex", paramNum=2 },
                poiIndex={ dataType="luaindex", name="poiIndex", paramNum=3 },
            },
        },
        ["EVENT_POI_UPDATED"] = {
            CODE=EVENT_POI_UPDATED,
            DESCR="EVENT_POI_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                zoneIndex={ dataType="luaindex", name="zoneIndex", paramNum=2 },
                poiIndex={ dataType="luaindex", name="poiIndex", paramNum=3 },
            },
        },
        ["EVENT_POWER_UPDATE"] = {
            CODE=EVENT_POWER_UPDATE,
            DESCR="EVENT_POWER_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                powerIndex={ dataType="luaindex", name="powerIndex", paramNum=3 },
                powerType={ dataType="integer", name="powerType", paramNum=4 },
                powerValue={ dataType="integer", name="powerValue", paramNum=5 },
                powerMax={ dataType="integer", name="powerMax", paramNum=6 },
                powerEffectiveMax={ dataType="integer", name="powerEffectiveMax", paramNum=7 },
            },
        },
        ["EVENT_PREFERRED_CAMPAIGN_CHANGED"] = {
            CODE=EVENT_PREFERRED_CAMPAIGN_CHANGED,
            DESCR="EVENT_PREFERRED_CAMPAIGN_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                newPreferredCampaignId={ dataType="integer", name="newPreferredCampaignId", paramNum=2 },
            },
        },
        ["EVENT_QUEST_ADDED"] = {
            CODE=EVENT_QUEST_ADDED,
            DESCR="EVENT_QUEST_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                questName={ dataType="string", name="questName", paramNum=3 },
                objectiveName={ dataType="string", name="objectiveName", paramNum=4 },
            },
        },
        ["EVENT_QUEST_ADVANCED"] = {
            CODE=EVENT_QUEST_ADVANCED,
            DESCR="EVENT_QUEST_ADVANCED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                questName={ dataType="string", name="questName", paramNum=3 },
                isPushed={ dataType="bool", name="isPushed", paramNum=4 },
                isComplete={ dataType="bool", name="isComplete", paramNum=5 },
                mainStepChanged={ dataType="bool", name="mainStepChanged", paramNum=6 },
            },
        },
        ["EVENT_QUEST_COMPLETE"] = {
            CODE=EVENT_QUEST_COMPLETE,
            DESCR="EVENT_QUEST_COMPLETE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                questName={ dataType="string", name="questName", paramNum=2 },
                level={ dataType="integer", name="level", paramNum=3 },
                previousExperience={ dataType="integer", name="previousExperience", paramNum=4 },
                currentExperience={ dataType="integer", name="currentExperience", paramNum=5 },
                rank={ dataType="integer", name="rank", paramNum=6 },
                previousPoints={ dataType="integer", name="previousPoints", paramNum=7 },
                currentPoints={ dataType="integer", name="currentPoints", paramNum=8 },
            },
        },
        ["EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL"] = {
            CODE=EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL,
            DESCR="EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_QUEST_COMPLETE_DIALOG"] = {
            CODE=EVENT_QUEST_COMPLETE_DIALOG,
            DESCR="EVENT_QUEST_COMPLETE_DIALOG",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
            },
        },
        ["EVENT_QUEST_CONDITION_COUNTER_CHANGED"] = {
            CODE=EVENT_QUEST_CONDITION_COUNTER_CHANGED,
            DESCR="EVENT_QUEST_CONDITION_COUNTER_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                questName={ dataType="string", name="questName", paramNum=3 },
                conditionText={ dataType="string", name="conditionText", paramNum=4 },
                conditionType={ dataType="integer", name="conditionType", paramNum=5 },
                currConditionVal={ dataType="integer", name="currConditionVal", paramNum=6 },
                newConditionVal={ dataType="integer", name="newConditionVal", paramNum=7 },
                conditionMax={ dataType="integer", name="conditionMax", paramNum=8 },
                isFailCondition={ dataType="bool", name="isFailCondition", paramNum=9 },
                stepOverrideText={ dataType="string", name="stepOverrideText", paramNum=10 },
                isPushed={ dataType="bool", name="isPushed", paramNum=11 },
                isComplete={ dataType="bool", name="isComplete", paramNum=12 },
                isConditionComplete={ dataType="bool", name="isConditionComplete", paramNum=13 },
                isStepHidden={ dataType="bool", name="isStepHidden", paramNum=14 },
            },
        },
        ["EVENT_QUEST_LIST_UPDATED"] = {
            CODE=EVENT_QUEST_LIST_UPDATED,
            DESCR="EVENT_QUEST_LIST_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_QUEST_LOG_IS_FULL"] = {
            CODE=EVENT_QUEST_LOG_IS_FULL,
            DESCR="EVENT_QUEST_LOG_IS_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_QUEST_OFFERED"] = {
            CODE=EVENT_QUEST_OFFERED,
            DESCR="EVENT_QUEST_OFFERED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_QUEST_OPTIONAL_STEP_ADVANCED"] = {
            CODE=EVENT_QUEST_OPTIONAL_STEP_ADVANCED,
            DESCR="EVENT_QUEST_OPTIONAL_STEP_ADVANCED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                text={ dataType="string", name="text", paramNum=2 },
            },
        },
        ["EVENT_QUEST_POSITION_REQUEST_COMPLETE"] = {
            CODE=EVENT_QUEST_POSITION_REQUEST_COMPLETE,
            DESCR="EVENT_QUEST_POSITION_REQUEST_COMPLETE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                taskId={ dataType="integer", name="taskId", paramNum=2 },
                pinType={ dataType="integer", name="pinType", paramNum=3 },
                xLoc={ dataType="number", name="xLoc", paramNum=4 },
                yLoc={ dataType="number", name="yLoc", paramNum=5 },
                areaRadius={ dataType="number", name="areaRadius", paramNum=6 },
                insideCurrentMapWorld={ dataType="bool", name="insideCurrentMapWorld", paramNum=7 },
                isBreadcrumb={ dataType="bool", name="isBreadcrumb", paramNum=8 },
            },
        },
        ["EVENT_QUEST_REMOVED"] = {
            CODE=EVENT_QUEST_REMOVED,
            DESCR="EVENT_QUEST_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                isCompleted={ dataType="bool", name="isCompleted", paramNum=2 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=3 },
                questName={ dataType="string", name="questName", paramNum=4 },
                zoneIndex={ dataType="luaindex", name="zoneIndex", paramNum=5 },
                poiIndex={ dataType="luaindex", name="poiIndex", paramNum=6 },
            },
        },
        ["EVENT_QUEST_SHARED"] = {
            CODE=EVENT_QUEST_SHARED,
            DESCR="EVENT_QUEST_SHARED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                questId={ dataType="integer", name="questId", paramNum=2 },
            },
        },
        ["EVENT_QUEST_SHARE_REMOVED"] = {
            CODE=EVENT_QUEST_SHARE_REMOVED,
            DESCR="EVENT_QUEST_SHARE_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                questId={ dataType="integer", name="questId", paramNum=2 },
            },
        },
        ["EVENT_QUEST_SHOW_JOURNAL_ENTRY"] = {
            CODE=EVENT_QUEST_SHOW_JOURNAL_ENTRY,
            DESCR="EVENT_QUEST_SHOW_JOURNAL_ENTRY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
            },
        },
        ["EVENT_QUEST_TIMER_PAUSED"] = {
            CODE=EVENT_QUEST_TIMER_PAUSED,
            DESCR="EVENT_QUEST_TIMER_PAUSED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                isPaused={ dataType="bool", name="isPaused", paramNum=3 },
            },
        },
        ["EVENT_QUEST_TIMER_UPDATED"] = {
            CODE=EVENT_QUEST_TIMER_UPDATED,
            DESCR="EVENT_QUEST_TIMER_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
            },
        },
        ["EVENT_QUEST_TOOL_UPDATED"] = {
            CODE=EVENT_QUEST_TOOL_UPDATED,
            DESCR="EVENT_QUEST_TOOL_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                journalIndex={ dataType="luaindex", name="journalIndex", paramNum=2 },
                questName={ dataType="string", name="questName", paramNum=3 },
            },
        },
        ["EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE"] = {
            CODE=EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE,
            DESCR="EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                response={ dataType="integer", name="response", paramNum=2 },
            },
        },
        ["EVENT_RAID_LEADERBOARD_DATA_CHANGED"] = {
            CODE=EVENT_RAID_LEADERBOARD_DATA_CHANGED,
            DESCR="EVENT_RAID_LEADERBOARD_DATA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED"] = {
            CODE=EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED,
            DESCR="EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RAID_PARTICIPATION_UPDATE"] = {
            CODE=EVENT_RAID_PARTICIPATION_UPDATE,
            DESCR="EVENT_RAID_PARTICIPATION_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RAID_REVIVE_COUNTER_UPDATE"] = {
            CODE=EVENT_RAID_REVIVE_COUNTER_UPDATE,
            DESCR="EVENT_RAID_REVIVE_COUNTER_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                currentCounter={ dataType="integer", name="currentCounter", paramNum=2 },
            },
        },
        ["EVENT_RAID_SCORE_NOTIFICATION_ADDED"] = {
            CODE=EVENT_RAID_SCORE_NOTIFICATION_ADDED,
            DESCR="EVENT_RAID_SCORE_NOTIFICATION_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                notificationId={ dataType="integer", name="notificationId", paramNum=2 },
            },
        },
        ["EVENT_RAID_SCORE_NOTIFICATION_REMOVED"] = {
            CODE=EVENT_RAID_SCORE_NOTIFICATION_REMOVED,
            DESCR="EVENT_RAID_SCORE_NOTIFICATION_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                notificationId={ dataType="integer", name="notificationId", paramNum=2 },
            },
        },
        ["EVENT_RAID_TIMER_STATE_UPDATE"] = {
            CODE=EVENT_RAID_TIMER_STATE_UPDATE,
            DESCR="EVENT_RAID_TIMER_STATE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RAID_TRIAL_COMPLETE"] = {
            CODE=EVENT_RAID_TRIAL_COMPLETE,
            DESCR="EVENT_RAID_TRIAL_COMPLETE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                trialName={ dataType="string", name="trialName", paramNum=2 },
                baseTimeMs={ dataType="integer", name="baseTimeMs", paramNum=3 },
                penaltyTimeMs={ dataType="integer", name="penaltyTimeMs", paramNum=4 },
                weekly={ dataType="bool", name="weekly", paramNum=5 },
            },
        },
        ["EVENT_RAID_TRIAL_FAILED"] = {
            CODE=EVENT_RAID_TRIAL_FAILED,
            DESCR="EVENT_RAID_TRIAL_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                trialName={ dataType="string", name="trialName", paramNum=2 },
                baseTimeMs={ dataType="integer", name="baseTimeMs", paramNum=3 },
                penaltyTimeMs={ dataType="integer", name="penaltyTimeMs", paramNum=4 },
                weekly={ dataType="bool", name="weekly", paramNum=5 },
            },
        },
        ["EVENT_RAID_TRIAL_NEW_BEST_TIME"] = {
            CODE=EVENT_RAID_TRIAL_NEW_BEST_TIME,
            DESCR="EVENT_RAID_TRIAL_NEW_BEST_TIME",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                trialName={ dataType="string", name="trialName", paramNum=2 },
                totalTimeMs={ dataType="integer", name="totalTimeMs", paramNum=3 },
                weekly={ dataType="bool", name="weekly", paramNum=4 },
            },
        },
        ["EVENT_RAID_TRIAL_STARTED"] = {
            CODE=EVENT_RAID_TRIAL_STARTED,
            DESCR="EVENT_RAID_TRIAL_STARTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                trialName={ dataType="string", name="trialName", paramNum=2 },
                weekly={ dataType="bool", name="weekly", paramNum=3 },
            },
        },
        ["EVENT_RAM_ESCORT_COUNT_UPDATE"] = {
            CODE=EVENT_RAM_ESCORT_COUNT_UPDATE,
            DESCR="EVENT_RAM_ESCORT_COUNT_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                numEscorts={ dataType="integer", name="numEscorts", paramNum=2 },
            },
        },
        ["EVENT_RANK_POINT_UPDATE"] = {
            CODE=EVENT_RANK_POINT_UPDATE,
            DESCR="EVENT_RANK_POINT_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                rankPoints={ dataType="integer", name="rankPoints", paramNum=3 },
                difference={ dataType="integer", name="difference", paramNum=4 },
            },
        },
        ["EVENT_RECIPE_ALREADY_KNOWN"] = {
            CODE=EVENT_RECIPE_ALREADY_KNOWN,
            DESCR="EVENT_RECIPE_ALREADY_KNOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RECIPE_LEARNED"] = {
            CODE=EVENT_RECIPE_LEARNED,
            DESCR="EVENT_RECIPE_LEARNED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                recipeListIndex={ dataType="luaindex", name="recipeListIndex", paramNum=2 },
                recipeIndex={ dataType="luaindex", name="recipeIndex", paramNum=3 },
            },
        },
        ["EVENT_REMOVE_ACTIVE_COMBAT_TIP"] = {
            CODE=EVENT_REMOVE_ACTIVE_COMBAT_TIP,
            DESCR="EVENT_REMOVE_ACTIVE_COMBAT_TIP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                activeCombatTipId={ dataType="integer", name="activeCombatTipId", paramNum=2 },
                result={ dataType="integer", name="result", paramNum=3 },
            },
        },
        ["EVENT_REMOVE_TUTORIAL"] = {
            CODE=EVENT_REMOVE_TUTORIAL,
            DESCR="EVENT_REMOVE_TUTORIAL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                tutorialIndex={ dataType="luaindex", name="tutorialIndex", paramNum=2 },
            },
        },
        ["EVENT_REQUIREMENTS_FAIL"] = {
            CODE=EVENT_REQUIREMENTS_FAIL,
            DESCR="EVENT_REQUIREMENTS_FAIL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                errorId={ dataType="integer", name="errorId", paramNum=2 },
            },
        },
        ["EVENT_RESURRECT_FAILURE"] = {
            CODE=EVENT_RESURRECT_FAILURE,
            DESCR="EVENT_RESURRECT_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                targetName={ dataType="string", name="targetName", paramNum=2 },
                reason={ dataType="integer", name="reason", paramNum=3 },
            },
        },
        ["EVENT_RESURRECT_REQUEST"] = {
            CODE=EVENT_RESURRECT_REQUEST,
            DESCR="EVENT_RESURRECT_REQUEST",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                requester={ dataType="string", name="requester", paramNum=2 },
                timeLeftToAccept={ dataType="integer", name="timeLeftToAccept", paramNum=3 },
            },
        },
        ["EVENT_RESURRECT_REQUEST_REMOVED"] = {
            CODE=EVENT_RESURRECT_REQUEST_REMOVED,
            DESCR="EVENT_RESURRECT_REQUEST_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RETICLE_HIDDEN_UPDATE"] = {
            CODE=EVENT_RETICLE_HIDDEN_UPDATE,
            DESCR="EVENT_RETICLE_HIDDEN_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                hidden={ dataType="bool", name="hidden", paramNum=2 },
            },
        },
        ["EVENT_RETICLE_TARGET_CHANGED"] = {
            CODE=EVENT_RETICLE_TARGET_CHANGED,
            DESCR="EVENT_RETICLE_TARGET_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_RETICLE_TARGET_PLAYER_CHANGED"] = {
            CODE=EVENT_RETICLE_TARGET_PLAYER_CHANGED,
            DESCR="EVENT_RETICLE_TARGET_PLAYER_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_REVENGE_KILL"] = {
            CODE=EVENT_REVENGE_KILL,
            DESCR="EVENT_REVENGE_KILL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                killedPlayerName={ dataType="string", name="killedPlayerName", paramNum=2 },
            },
        },
        ["EVENT_SCREENSHOT_SAVED"] = {
            CODE=EVENT_SCREENSHOT_SAVED,
            DESCR="EVENT_SCREENSHOT_SAVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                directory={ dataType="string", name="directory", paramNum=2 },
                filename={ dataType="string", name="filename", paramNum=3 },
            },
        },
        ["EVENT_SCRIPTED_WORLD_EVENT_INVITE"] = {
            CODE=EVENT_SCRIPTED_WORLD_EVENT_INVITE,
            DESCR="EVENT_SCRIPTED_WORLD_EVENT_INVITE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                eventId={ dataType="integer", name="eventId", paramNum=2 },
                scriptedEventName={ dataType="string", name="scriptedEventName", paramNum=3 },
                inviterName={ dataType="string", name="inviterName", paramNum=4 },
                questName={ dataType="string", name="questName", paramNum=5 },
            },
        },
        ["EVENT_SELL_RECEIPT"] = {
            CODE=EVENT_SELL_RECEIPT,
            DESCR="EVENT_SELL_RECEIPT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemName={ dataType="string", name="itemName", paramNum=2 },
                itemQuantity={ dataType="integer", name="itemQuantity", paramNum=3 },
                money={ dataType="integer", name="money", paramNum=4 },
            },
        },
        ["EVENT_SERVER_SHUTDOWN_INFO"] = {
            CODE=EVENT_SERVER_SHUTDOWN_INFO,
            DESCR="EVENT_SERVER_SHUTDOWN_INFO",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                action={ dataType="integer", name="action", paramNum=2 },
                timeRemaining={ dataType="integer", name="timeRemaining", paramNum=3 },
            },
        },
        ["EVENT_SHOW_BOOK"] = {
            CODE=EVENT_SHOW_BOOK,
            DESCR="EVENT_SHOW_BOOK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bookTitle={ dataType="string", name="bookTitle", paramNum=2 },
                body={ dataType="string", name="body", paramNum=3 },
                medium={ dataType="integer", name="medium", paramNum=4 },
                showTitle={ dataType="bool", name="showTitle", paramNum=5 },
            },
        },
        ["EVENT_SHOW_TREASURE_MAP"] = {
            CODE=EVENT_SHOW_TREASURE_MAP,
            DESCR="EVENT_SHOW_TREASURE_MAP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                treasureMapIndex={ dataType="luaindex", name="treasureMapIndex", paramNum=2 },
            },
        },
        ["EVENT_SIEGE_BUSY"] = {
            CODE=EVENT_SIEGE_BUSY,
            DESCR="EVENT_SIEGE_BUSY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                siegeName={ dataType="string", name="siegeName", paramNum=2 },
            },
        },
        ["EVENT_SIEGE_CONTROL_ANOTHER_PLAYER"] = {
            CODE=EVENT_SIEGE_CONTROL_ANOTHER_PLAYER,
            DESCR="EVENT_SIEGE_CONTROL_ANOTHER_PLAYER",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                siegeName={ dataType="string", name="siegeName", paramNum=2 },
            },
        },
        ["EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM"] = {
            CODE=EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM,
            DESCR="EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR"] = {
            CODE=EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR,
            DESCR="EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SIEGE_FIRE_FAILED_COOLDOWN"] = {
            CODE=EVENT_SIEGE_FIRE_FAILED_COOLDOWN,
            DESCR="EVENT_SIEGE_FIRE_FAILED_COOLDOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SIEGE_FIRE_FAILED_RETARGETING"] = {
            CODE=EVENT_SIEGE_FIRE_FAILED_RETARGETING,
            DESCR="EVENT_SIEGE_FIRE_FAILED_RETARGETING",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL"] = {
            CODE=EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL,
            DESCR="EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SIEGE_PACK_FAILED_NOT_CREATOR"] = {
            CODE=EVENT_SIEGE_PACK_FAILED_NOT_CREATOR,
            DESCR="EVENT_SIEGE_PACK_FAILED_NOT_CREATOR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SKILLS_FULL_UPDATE"] = {
            CODE=EVENT_SKILLS_FULL_UPDATE,
            DESCR="EVENT_SKILLS_FULL_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SKILL_FORCE_RESPEC"] = {
            CODE=EVENT_SKILL_FORCE_RESPEC,
            DESCR="EVENT_SKILL_FORCE_RESPEC",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                note={ dataType="string", name="note", paramNum=2 },
            },
        },
        ["EVENT_SKILL_LINE_ADDED"] = {
            CODE=EVENT_SKILL_LINE_ADDED,
            DESCR="EVENT_SKILL_LINE_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                skillType={ dataType="integer", name="skillType", paramNum=2 },
                skillIndex={ dataType="luaindex", name="skillIndex", paramNum=3 },
            },
        },
        ["EVENT_SKILL_POINTS_CHANGED"] = {
            CODE=EVENT_SKILL_POINTS_CHANGED,
            DESCR="EVENT_SKILL_POINTS_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                pointsBefore={ dataType="integer", name="pointsBefore", paramNum=2 },
                pointsNow={ dataType="integer", name="pointsNow", paramNum=3 },
                partialPointsBefore={ dataType="integer", name="partialPointsBefore", paramNum=4 },
                partialPointsNow={ dataType="integer", name="partialPointsNow", paramNum=5 },
            },
        },
        ["EVENT_SKILL_RANK_UPDATE"] = {
            CODE=EVENT_SKILL_RANK_UPDATE,
            DESCR="EVENT_SKILL_RANK_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                skillType={ dataType="integer", name="skillType", paramNum=2 },
                skillIndex={ dataType="luaindex", name="skillIndex", paramNum=3 },
                rank={ dataType="luaindex", name="rank", paramNum=4 },
            },
        },
        ["EVENT_SKILL_XP_UPDATE"] = {
            CODE=EVENT_SKILL_XP_UPDATE,
            DESCR="EVENT_SKILL_XP_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                skillType={ dataType="integer", name="skillType", paramNum=2 },
                skillIndex={ dataType="luaindex", name="skillIndex", paramNum=3 },
                reason={ dataType="integer", name="reason", paramNum=4 },
                rank={ dataType="luaindex", name="rank", paramNum=5 },
                previousXP={ dataType="integer", name="previousXP", paramNum=6 },
                currentXP={ dataType="integer", name="currentXP", paramNum=7 },
            },
        },
        ["EVENT_SLOT_IS_LOCKED_FAILURE"] = {
            CODE=EVENT_SLOT_IS_LOCKED_FAILURE,
            DESCR="EVENT_SLOT_IS_LOCKED_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                bagId={ dataType="integer", name="bagId", paramNum=2 },
                slotId={ dataType="integer", name="slotId", paramNum=3 },
            },
        },
        ["EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED"] = {
            CODE=EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
            DESCR="EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                craftingSkillType={ dataType="integer", name="craftingSkillType", paramNum=2 },
                researchLineIndex={ dataType="luaindex", name="researchLineIndex", paramNum=3 },
                traitIndex={ dataType="luaindex", name="traitIndex", paramNum=4 },
            },
        },
        ["EVENT_SMITHING_TRAIT_RESEARCH_STARTED"] = {
            CODE=EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
            DESCR="EVENT_SMITHING_TRAIT_RESEARCH_STARTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                craftingSkillType={ dataType="integer", name="craftingSkillType", paramNum=2 },
                researchLineIndex={ dataType="luaindex", name="researchLineIndex", paramNum=3 },
                traitIndex={ dataType="luaindex", name="traitIndex", paramNum=4 },
            },
        },
        ["EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE"] = {
            CODE=EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE,
            DESCR="EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_STABLE_FULL"] = {
            CODE=EVENT_STABLE_FULL,
            DESCR="EVENT_STABLE_FULL",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STABLE_INTERACT_END"] = {
            CODE=EVENT_STABLE_INTERACT_END,
            DESCR="EVENT_STABLE_INTERACT_END",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STABLE_INTERACT_START"] = {
            CODE=EVENT_STABLE_INTERACT_START,
            DESCR="EVENT_STABLE_INTERACT_START",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_START_FAST_TRAVEL_INTERACTION"] = {
            CODE=EVENT_START_FAST_TRAVEL_INTERACTION,
            DESCR="EVENT_START_FAST_TRAVEL_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                nodeIndex={ dataType="luaindex", name="nodeIndex", paramNum=2 },
            },
        },
        ["EVENT_START_FAST_TRAVEL_KEEP_INTERACTION"] = {
            CODE=EVENT_START_FAST_TRAVEL_KEEP_INTERACTION,
            DESCR="EVENT_START_FAST_TRAVEL_KEEP_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                keepId={ dataType="integer", name="keepId", paramNum=2 },
            },
        },
        ["EVENT_START_KEEP_GUILD_CLAIM_INTERACTION"] = {
            CODE=EVENT_START_KEEP_GUILD_CLAIM_INTERACTION,
            DESCR="EVENT_START_KEEP_GUILD_CLAIM_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_START_KEEP_GUILD_RELEASE_INTERACTION"] = {
            CODE=EVENT_START_KEEP_GUILD_RELEASE_INTERACTION,
            DESCR="EVENT_START_KEEP_GUILD_RELEASE_INTERACTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_START_SOUL_GEM_RESURRECTION"] = {
            CODE=EVENT_START_SOUL_GEM_RESURRECTION,
            DESCR="EVENT_START_SOUL_GEM_RESURRECTION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                durationMs={ dataType="integer", name="durationMs", paramNum=2 },
            },
        },
        ["EVENT_STATS_UPDATED"] = {
            CODE=EVENT_STATS_UPDATED,
            DESCR="EVENT_STATS_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_STEALTH_STATE_CHANGED"] = {
            CODE=EVENT_STEALTH_STATE_CHANGED,
            DESCR="EVENT_STEALTH_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                stealthState={ dataType="integer", name="stealthState", paramNum=3 },
            },
        },
        ["EVENT_STORE_FAILURE"] = {
            CODE=EVENT_STORE_FAILURE,
            DESCR="EVENT_STORE_FAILURE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_STUCK_BEGIN"] = {
            CODE=EVENT_STUCK_BEGIN,
            DESCR="EVENT_STUCK_BEGIN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_CANCELED"] = {
            CODE=EVENT_STUCK_CANCELED,
            DESCR="EVENT_STUCK_CANCELED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_COMPLETE"] = {
            CODE=EVENT_STUCK_COMPLETE,
            DESCR="EVENT_STUCK_COMPLETE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_ERROR_ALREADY_IN_PROGRESS"] = {
            CODE=EVENT_STUCK_ERROR_ALREADY_IN_PROGRESS,
            DESCR="EVENT_STUCK_ERROR_ALREADY_IN_PROGRESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_ERROR_INVALID_LOCATION"] = {
            CODE=EVENT_STUCK_ERROR_INVALID_LOCATION,
            DESCR="EVENT_STUCK_ERROR_INVALID_LOCATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_ERROR_IN_COMBAT"] = {
            CODE=EVENT_STUCK_ERROR_IN_COMBAT,
            DESCR="EVENT_STUCK_ERROR_IN_COMBAT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STUCK_ERROR_ON_COOLDOWN"] = {
            CODE=EVENT_STUCK_ERROR_ON_COOLDOWN,
            DESCR="EVENT_STUCK_ERROR_ON_COOLDOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_STYLE_LEARNED"] = {
            CODE=EVENT_STYLE_LEARNED,
            DESCR="EVENT_STYLE_LEARNED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                styleIndex={ dataType="luaindex", name="styleIndex", paramNum=2 },
                chapterIndex={ dataType="integer", name="chapterIndex", paramNum=3 },
            },
        },
        ["EVENT_SYNERGY_ABILITY_CHANGED"] = {
            CODE=EVENT_SYNERGY_ABILITY_CHANGED,
            DESCR="EVENT_SYNERGY_ABILITY_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TARGET_CHANGED"] = {
            CODE=EVENT_TARGET_CHANGED,
            DESCR="EVENT_TARGET_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_TITLE_UPDATE"] = {
            CODE=EVENT_TITLE_UPDATE,
            DESCR="EVENT_TITLE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_TRACKING_UPDATE"] = {
            CODE=EVENT_TRACKING_UPDATE,
            DESCR="EVENT_TRACKING_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY"] = {
            CODE=EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY,
            DESCR="EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_CANCELED"] = {
            CODE=EVENT_TRADE_CANCELED,
            DESCR="EVENT_TRADE_CANCELED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                cancelerName={ dataType="string", name="cancelerName", paramNum=2 },
            },
        },
        ["EVENT_TRADE_CONFIRMATION_CHANGED"] = {
            CODE=EVENT_TRADE_CONFIRMATION_CHANGED,
            DESCR="EVENT_TRADE_CONFIRMATION_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                who={ dataType="integer", name="who", paramNum=2 },
                level={ dataType="integer", name="level", paramNum=3 },
            },
        },
        ["EVENT_TRADE_ELEVATION_FAILED"] = {
            CODE=EVENT_TRADE_ELEVATION_FAILED,
            DESCR="EVENT_TRADE_ELEVATION_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                itemName={ dataType="string", name="itemName", paramNum=3 },
            },
        },
        ["EVENT_TRADE_FAILED"] = {
            CODE=EVENT_TRADE_FAILED,
            DESCR="EVENT_TRADE_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
            },
        },
        ["EVENT_TRADE_INVITE_ACCEPTED"] = {
            CODE=EVENT_TRADE_INVITE_ACCEPTED,
            DESCR="EVENT_TRADE_INVITE_ACCEPTED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_INVITE_CANCELED"] = {
            CODE=EVENT_TRADE_INVITE_CANCELED,
            DESCR="EVENT_TRADE_INVITE_CANCELED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_INVITE_CONSIDERING"] = {
            CODE=EVENT_TRADE_INVITE_CONSIDERING,
            DESCR="EVENT_TRADE_INVITE_CONSIDERING",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                inviter={ dataType="string", name="inviter", paramNum=2 },
            },
        },
        ["EVENT_TRADE_INVITE_DECLINED"] = {
            CODE=EVENT_TRADE_INVITE_DECLINED,
            DESCR="EVENT_TRADE_INVITE_DECLINED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_INVITE_FAILED"] = {
            CODE=EVENT_TRADE_INVITE_FAILED,
            DESCR="EVENT_TRADE_INVITE_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                name={ dataType="string", name="name", paramNum=3 },
            },
        },
        ["EVENT_TRADE_INVITE_REMOVED"] = {
            CODE=EVENT_TRADE_INVITE_REMOVED,
            DESCR="EVENT_TRADE_INVITE_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADE_INVITE_WAITING"] = {
            CODE=EVENT_TRADE_INVITE_WAITING,
            DESCR="EVENT_TRADE_INVITE_WAITING",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                invitee={ dataType="string", name="invitee", paramNum=2 },
            },
        },
        ["EVENT_TRADE_ITEM_ADDED"] = {
            CODE=EVENT_TRADE_ITEM_ADDED,
            DESCR="EVENT_TRADE_ITEM_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                who={ dataType="integer", name="who", paramNum=2 },
                tradeIndex={ dataType="luaindex", name="tradeIndex", paramNum=3 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=4 },
            },
        },
        ["EVENT_TRADE_ITEM_ADD_FAILED"] = {
            CODE=EVENT_TRADE_ITEM_ADD_FAILED,
            DESCR="EVENT_TRADE_ITEM_ADD_FAILED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                reason={ dataType="integer", name="reason", paramNum=2 },
                itemName={ dataType="string", name="itemName", paramNum=3 },
            },
        },
        ["EVENT_TRADE_ITEM_REMOVED"] = {
            CODE=EVENT_TRADE_ITEM_REMOVED,
            DESCR="EVENT_TRADE_ITEM_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                who={ dataType="integer", name="who", paramNum=2 },
                tradeIndex={ dataType="luaindex", name="tradeIndex", paramNum=3 },
                itemSoundCategory={ dataType="integer", name="itemSoundCategory", paramNum=4 },
            },
        },
        ["EVENT_TRADE_ITEM_UPDATED"] = {
            CODE=EVENT_TRADE_ITEM_UPDATED,
            DESCR="EVENT_TRADE_ITEM_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                who={ dataType="integer", name="who", paramNum=2 },
                tradeIndex={ dataType="luaindex", name="tradeIndex", paramNum=3 },
            },
        },
        ["EVENT_TRADE_MONEY_CHANGED"] = {
            CODE=EVENT_TRADE_MONEY_CHANGED,
            DESCR="EVENT_TRADE_MONEY_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                who={ dataType="integer", name="who", paramNum=2 },
                money={ dataType="integer", name="money", paramNum=3 },
            },
        },
        ["EVENT_TRADE_SUCCEEDED"] = {
            CODE=EVENT_TRADE_SUCCEEDED,
            DESCR="EVENT_TRADE_SUCCEEDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRADING_HOUSE_AWAITING_RESPONSE"] = {
            CODE=EVENT_TRADING_HOUSE_AWAITING_RESPONSE,
            DESCR="EVENT_TRADING_HOUSE_AWAITING_RESPONSE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                responseType={ dataType="integer", name="responseType", paramNum=2 },
            },
        },
        ["EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE"] = {
            CODE=EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE,
            DESCR="EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                pendingPurchaseIndex={ dataType="luaindex", name="pendingPurchaseIndex", paramNum=2 },
            },
        },
        ["EVENT_TRADING_HOUSE_ERROR"] = {
            CODE=EVENT_TRADING_HOUSE_ERROR,
            DESCR="EVENT_TRADING_HOUSE_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                errorCode={ dataType="integer", name="errorCode", paramNum=2 },
            },
        },
        ["EVENT_TRADING_HOUSE_OPERATION_TIME_OUT"] = {
            CODE=EVENT_TRADING_HOUSE_OPERATION_TIME_OUT,
            DESCR="EVENT_TRADING_HOUSE_OPERATION_TIME_OUT",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                responseType={ dataType="integer", name="responseType", paramNum=2 },
            },
        },
        ["EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE"] = {
            CODE=EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE,
            DESCR="EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                slotId={ dataType="integer", name="slotId", paramNum=2 },
                isPending={ dataType="bool", name="isPending", paramNum=3 },
            },
        },
        ["EVENT_TRADING_HOUSE_RESPONSE_RECEIVED"] = {
            CODE=EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,
            DESCR="EVENT_TRADING_HOUSE_RESPONSE_RECEIVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                responseType={ dataType="integer", name="responseType", paramNum=2 },
                result={ dataType="integer", name="result", paramNum=3 },
            },
        },
        ["EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE"] = {
            CODE=EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE,
            DESCR="EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                cooldownMilliseconds={ dataType="integer", name="cooldownMilliseconds", paramNum=2 },
            },
        },
        ["EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED"] = {
            CODE=EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED,
            DESCR="EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                guildId={ dataType="integer", name="guildId", paramNum=2 },
                numItemsOnPage={ dataType="integer", name="numItemsOnPage", paramNum=3 },
                currentPage={ dataType="integer", name="currentPage", paramNum=4 },
                hasMorePages={ dataType="bool", name="hasMorePages", paramNum=5 },
            },
        },
        ["EVENT_TRADING_HOUSE_STATUS_RECEIVED"] = {
            CODE=EVENT_TRADING_HOUSE_STATUS_RECEIVED,
            DESCR="EVENT_TRADING_HOUSE_STATUS_RECEIVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_TRAIT_LEARNED"] = {
            CODE=EVENT_TRAIT_LEARNED,
            DESCR="EVENT_TRAIT_LEARNED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                itemName={ dataType="string", name="itemName", paramNum=2 },
                itemTrait={ dataType="string", name="itemTrait", paramNum=3 },
            },
        },
        ["EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED"] = {
            CODE=EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED,
            DESCR="EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                enabled={ dataType="bool", name="enabled", paramNum=2 },
            },
        },
        ["EVENT_UI_ERROR"] = {
            CODE=EVENT_UI_ERROR,
            DESCR="EVENT_UI_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                stringId={ dataType="integer", name="stringId", paramNum=2 },
            },
        },
        ["EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED"] = {
            CODE=EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,
            DESCR="EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                unitAttributeVisual={ dataType="integer", name="unitAttributeVisual", paramNum=3 },
                statType={ dataType="integer", name="statType", paramNum=4 },
                attributeType={ dataType="integer", name="attributeType", paramNum=5 },
                powerType={ dataType="integer", name="powerType", paramNum=6 },
                value={ dataType="number", name="value", paramNum=7 },
                maxValue={ dataType="number", name="maxValue", paramNum=8 },
                sequenceId={ dataType="integer", name="maxValue", paramNum=9 },
            },
        },
        ["EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED"] = {
            CODE=EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
            DESCR="EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                unitAttributeVisual={ dataType="integer", name="unitAttributeVisual", paramNum=3 },
                statType={ dataType="integer", name="statType", paramNum=4 },
                attributeType={ dataType="integer", name="attributeType", paramNum=5 },
                powerType={ dataType="integer", name="powerType", paramNum=6 },
                value={ dataType="number", name="value", paramNum=7 },
                maxValue={ dataType="number", name="maxValue", paramNum=8 },
            },
        },
        ["EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED"] = {
            CODE=EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,
            DESCR="EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                unitAttributeVisual={ dataType="integer", name="unitAttributeVisual", paramNum=3 },
                statType={ dataType="integer", name="statType", paramNum=4 },
                attributeType={ dataType="integer", name="attributeType", paramNum=5 },
                powerType={ dataType="integer", name="powerType", paramNum=6 },
                oldValue={ dataType="number", name="oldValue", paramNum=7 },
                newValue={ dataType="number", name="newValue", paramNum=8 },
                oldMaxValue={ dataType="number", name="oldMaxValue", paramNum=9 },
                newMaxValue={ dataType="number", name="newMaxValue", paramNum=10 },
            },
        },
        ["EVENT_UNIT_CREATED"] = {
            CODE=EVENT_UNIT_CREATED,
            DESCR="EVENT_UNIT_CREATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_UNIT_DEATH_STATE_CHANGED"] = {
            CODE=EVENT_UNIT_DEATH_STATE_CHANGED,
            DESCR="EVENT_UNIT_DEATH_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                isDead={ dataType="bool", name="isDead", paramNum=3 },
            },
        },
        ["EVENT_UNIT_DESTROYED"] = {
            CODE=EVENT_UNIT_DESTROYED,
            DESCR="EVENT_UNIT_DESTROYED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_UNIT_FRAME_UPDATE"] = {
            CODE=EVENT_UNIT_FRAME_UPDATE,
            DESCR="EVENT_UNIT_FRAME_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
            },
        },
        ["EVENT_UNLOCKED_DYES_UPDATED"] = {
            CODE=EVENT_UNLOCKED_DYES_UPDATED,
            DESCR="EVENT_UNLOCKED_DYES_UPDATED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_UPDATE_BUYBACK"] = {
            CODE=EVENT_UPDATE_BUYBACK,
            DESCR="EVENT_UPDATE_BUYBACK",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_VETERAN_DIFFICULTY_CHANGED"] = {
            CODE=EVENT_VETERAN_DIFFICULTY_CHANGED,
            DESCR="EVENT_VETERAN_DIFFICULTY_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                isDifficult={ dataType="bool", name="isDifficult", paramNum=3 },
            },
        },
        -- "EVENT_VETERAN_POINTS_GAIN" - function removed, combined with EVENT_EXPERIENCE_GAIN
        -- "EVENT_VETERAN_POINTS_UPDATE" function renamed to EVENT_CHAMPION_POINTS_UPDATE
        ["EVENT_CHAMPION_POINTS_UPDATE"] = {
            CODE=EVENT_CHAMPION_POINTS_UPDATE,
            DESCR="EVENT_CHAMPION_POINTS_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                oldChampionPoints={ dataType="integer", name="oldChampionPoints", paramNum=3 },
                currentPoints={ dataType="integer", name="currentPoints", paramNum=4 },
                maxPoints={ dataType="integer", name="maxPoints", paramNum=4 },
                reason={ dataType="integer", name="reason", paramNum=5 },
            },
        },
        -- "EVENT_VETERAN_RANK_UPDATE" function removed, no longer valid event
        ["EVENT_VIBRATION"] = {
            CODE=EVENT_VIBRATION,
            DESCR="EVENT_VIBRATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                duration={ dataType="integer", name="duration", paramNum=2 },
                coarseMotor={ dataType="number", name="coarseMotor", paramNum=3 },
                fineMotor={ dataType="number", name="fineMotor", paramNum=4 },
                leftTriggerMotor={ dataType="number", name="leftTriggerMotor", paramNum=5 },
                rightTriggerMotor={ dataType="number", name="rightTriggerMotor", paramNum=6 },
            },
        },
        ["EVENT_WEAPON_SWAP_LOCKED"] = {
            CODE=EVENT_WEAPON_SWAP_LOCKED,
            DESCR="EVENT_WEAPON_SWAP_LOCKED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                swapLevel={ dataType="integer", name="swapLevel", paramNum=2 },
            },
        },
        ["EVENT_WEREWOLF_STATE_CHANGED"] = {
            CODE=EVENT_WEREWOLF_STATE_CHANGED,
            DESCR="EVENT_WEREWOLF_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                werewolf={ dataType="bool", name="werewolf", paramNum=2 },
            },
        },
        ["EVENT_ZONE_CHANGED"] = {
            CODE=EVENT_ZONE_CHANGED,
            DESCR="EVENT_ZONE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                zoneName={ dataType="string", name="zoneName", paramNum=2 },
                subZoneName={ dataType="string", name="subZoneName", paramNum=3 },
                newSubzone={ dataType="bool", name="newSubzone", paramNum=4 },
            },
        },
        ["EVENT_ZONE_CHANNEL_CHANGED"] = {
            CODE=EVENT_ZONE_CHANNEL_CHANGED,
            DESCR="EVENT_ZONE_CHANNEL_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ZONE_SCORING_CHANGED"] = {
            CODE=EVENT_ZONE_SCORING_CHANGED,
            DESCR="EVENT_ZONE_SCORING_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_ZONE_UPDATE"] = {
            CODE=EVENT_ZONE_UPDATE,
            DESCR="EVENT_ZONE_UPDATE",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                unitTag={ dataType="string", name="unitTag", paramNum=2 },
                newZoneName={ dataType="string", name="newZoneName", paramNum=3 },
            },
        },
        ["EVENT_ACTION_LAYER_POPPED"] = {
            CODE=EVENT_ACTION_LAYER_POPPED,
            DESCR="EVENT_ACTION_LAYER_POPPED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                layerIndex={ dataType="luaindex", name="layerIndex", paramNum=2 },
                activeLayerIndex={ dataType="luaindex", name="activeLayerIndex", paramNum=3 },
            },
        },
        ["EVENT_ACTION_LAYER_PUSHED"] = {
            CODE=EVENT_ACTION_LAYER_PUSHED,
            DESCR="EVENT_ACTION_LAYER_PUSHED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                layerIndex={ dataType="luaindex", name="layerIndex", paramNum=2 },
                activeLayerIndex={ dataType="luaindex", name="activeLayerIndex", paramNum=3 },
            },
        },
        ["EVENT_ADD_ON_LOADED"] = {
            CODE=EVENT_ADD_ON_LOADED,
            DESCR="EVENT_ADD_ON_LOADED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                addonName={ dataType="string", name="addonName", paramNum=2 },
            },
        },
        ["EVENT_CAPS_LOCK_STATE_CHANGED"] = {
            CODE=EVENT_CAPS_LOCK_STATE_CHANGED,
            DESCR="EVENT_CAPS_LOCK_STATE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                capsLockEnabled={ dataType="bool", name="capsLockEnabled", paramNum=2 },
            },
        },
        ["EVENT_GAMEPAD_PREFERRED_MODE_CHANGED"] = {
            CODE=EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
            DESCR="EVENT_GAMEPAD_PREFERRED_MODE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                gamepadPreferred={ dataType="bool", name="gamepadPreferred", paramNum=2 },
            },
        },
        ["EVENT_GLOBAL_MOUSE_DOWN"] = {
            CODE=EVENT_GLOBAL_MOUSE_DOWN,
            DESCR="EVENT_GLOBAL_MOUSE_DOWN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                button={ dataType="integer", name="button", paramNum=2 },
                ctrl={ dataType="bool", name="ctrl", paramNum=3 },
                alt={ dataType="bool", name="alt", paramNum=4 },
                shift={ dataType="bool", name="shift", paramNum=5 },
                command={ dataType="bool", name="command", paramNum=6 },
            },
        },
        ["EVENT_GLOBAL_MOUSE_UP"] = {
            CODE=EVENT_GLOBAL_MOUSE_UP,
            DESCR="EVENT_GLOBAL_MOUSE_UP",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                button={ dataType="integer", name="button", paramNum=2 },
                ctrl={ dataType="bool", name="ctrl", paramNum=3 },
                alt={ dataType="bool", name="alt", paramNum=4 },
                shift={ dataType="bool", name="shift", paramNum=5 },
                command={ dataType="bool", name="command", paramNum=6 },
            },
        },
        ["EVENT_GUI_HIDDEN"] = {
            CODE=EVENT_GUI_HIDDEN,
            DESCR="EVENT_GUI_HIDDEN",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                guiName={ dataType="string", name="guiName", paramNum=2 },
                hidden={ dataType="bool", name="hidden", paramNum=3 },
            },
        },
        ["EVENT_INPUT_LANGUAGE_CHANGED"] = {
            CODE=EVENT_INPUT_LANGUAGE_CHANGED,
            DESCR="EVENT_INPUT_LANGUAGE_CHANGED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_KEYBINDINGS_LOADED"] = {
            CODE=EVENT_KEYBINDINGS_LOADED,
            DESCR="EVENT_KEYBINDINGS_LOADED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_KEYBINDING_CLEARED"] = {
            CODE=EVENT_KEYBINDING_CLEARED,
            DESCR="EVENT_KEYBINDING_CLEARED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                layerIndex={ dataType="luaindex", name="layerIndex", paramNum=2 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=3 },
                actionIndex={ dataType="luaindex", name="actionIndex", paramNum=4 },
                bindingIndex={ dataType="luaindex", name="bindingIndex", paramNum=5 },
            },
        },
        ["EVENT_KEYBINDING_SET"] = {
            CODE=EVENT_KEYBINDING_SET,
            DESCR="EVENT_KEYBINDING_SET",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                layerIndex={ dataType="luaindex", name="layerIndex", paramNum=2 },
                categoryIndex={ dataType="luaindex", name="categoryIndex", paramNum=3 },
                actionIndex={ dataType="luaindex", name="actionIndex", paramNum=4 },
                bindingIndex={ dataType="luaindex", name="bindingIndex", paramNum=5 },
                keyCode={ dataType="integer", name="keyCode", paramNum=6 },
                mod1={ dataType="integer", name="mod1", paramNum=7 },
                mod2={ dataType="integer", name="mod2", paramNum=8 },
                mod3={ dataType="integer", name="mod3", paramNum=9 },
                mod4={ dataType="integer", name="mod4", paramNum=10 },
            },
        },
        ["EVENT_LUA_ERROR"] = {
            CODE=EVENT_LUA_ERROR,
            DESCR="EVENT_LUA_ERROR",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                error={ dataType="string", name="error", paramNum=2 },
            },
        },
        ["EVENT_LUA_LOW_MEMORY"] = {
            CODE=EVENT_LUA_LOW_MEMORY,
            DESCR="EVENT_LUA_LOW_MEMORY",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
            },
        },
        ["EVENT_SCREEN_RESIZED"] = {
            CODE=EVENT_SCREEN_RESIZED,
            DESCR="EVENT_SCREEN_RESIZED",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                x={ dataType="integer", name="x", paramNum=2 },
                y={ dataType="integer", name="y", paramNum=3 },
            },
        },
        ["EVENT_SCRIPT_ACCESS_VIOLATION"] = {
            CODE=EVENT_SCRIPT_ACCESS_VIOLATION,
            DESCR="EVENT_SCRIPT_ACCESS_VIOLATION",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                protectedFunctionName={ dataType="string", name="protectedFunctionName", paramNum=2 },
            },
        },
        ["EVENT_SHOW_GUI"] = {
            CODE=EVENT_SHOW_GUI,
            DESCR="EVENT_SHOW_GUI",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                guiName={ dataType="string", name="guiName", paramNum=2 },
                desiredStateName={ dataType="string", name="desiredStateName", paramNum=3 },
            },
        },
        ["EVENT_UPDATE_GUI_LOADING_PROGRESS"] = {
            CODE=EVENT_UPDATE_GUI_LOADING_PROGRESS,
            DESCR="EVENT_UPDATE_GUI_LOADING_PROGRESS",
            PARAMS={
                eventCode={ dataType="integer", name="eventCode", paramNum=1 },
                guiName={ dataType="string", name="guiName", paramNum=2 },
                assetsLoaded={ dataType="integer", name="assetsLoaded", paramNum=3 },
                assetsTotal={ dataType="integer", name="assetsTotal", paramNum=4 },
            },
        },
	}
	for e,t in pairs(LWF4.data.GameEventTable) do if t.CODE ~= nil then LWF4.data.GameEventsByCode[ t.CODE ] = t end end

	LWF4.data.__hydrated = true
end
lwf4.__register = function()
	if not LWF4 then return end
	if LWF4.__updateTicRegistered then return end
	EVENT_MANAGER:RegisterForUpdate("LWF4_UpdateTic", 100, LWF4.__tic)
	LWF4.__updateTicRegistered = true
end

lwf4.__tic = function()
	if not LWF4 then return end
	local libAddonHook = "LWF4_StandardEventRegister"
	if LWF4.__internal.table_count(LWF4.mem.EventRegistry) > 0 then
		for e,v in pairs(LWF4.mem.EventRegistry) do
			if not LWF4.mem._NumRegisteredToGlobalHandler[e] then LWF4.mem._NumRegisteredToGlobalHandler[e] = 0 end
			if not LWF4.mem._RegisteredToGlobalHandler[e] then LWF4.mem._RegisteredToGlobalHandler[e] = false end
			for a,t in pairs(v) do
				if t.Unregister and not t.Unregistered then
					LWF4.mem._NumRegisteredToGlobalHandler[e] = LWF4.mem._NumRegisteredToGlobalHandler[e] - 1
					t.Unregistered = true
				elseif not t.Registered and not t.Unregister then
					LWF4.mem._NumRegisteredToGlobalHandler[e] = LWF4.mem._NumRegisteredToGlobalHandler[e] + 1
					t.Registered = true
				end
			end

			if LWF4.mem._NumRegisteredToGlobalHandler[e] > 0 then
				if not LWF4.mem._RegisteredToGlobalHandler[e] then
					EVENT_MANAGER:RegisterForEvent(
						libAddonHook,
						LWF4.data.GameEventTable[e].CODE,
						LWF4.__eventHandler)
					LWF4.mem._RegisteredToGlobalHandler[e] = true
				end
			else
				if LWF4.mem._RegisteredToGlobalHandler[e] then
					if LWF4.mem._hasUnregistered[LWF4.data.GameEventTable[e].CODE] ~= nil then
						if LWF4.mem._hasUnregistered[LWF4.data.GameEventTable[e].CODE][libAddonHook] == nil then
							EVENT_MANAGER:UnregisterEvent(libAddonHook, LWF4.data.GameEventTable[e].CODE)
							LWF4.mem._hasUnregistered[LWF4.data.GameEventTable[e].CODE][libAddonHook] = true
						end
					end
				end
			end
		end
	end

	LWF4.__internal.ToggleUIFrames()

	for k,t in pairs(LWF4.mem.TicRegistry) do
		if t.Callback then
			if t.Buffer then
				if LWF4.__internal.BufferPause(k, t.Buffer) then t.Callback() end
			else t.Callback() end
		end
	end
end
lwf4.__eventHandler = function( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 )
	if not LWF4 then return end
	LWF4.__hydrate()
	local e = LWF4.data.GameEventsByCode[ arg1 ]
	if e == nil then return end
	if LWF4.mem.EventRegistry[ e.DESCR ] == nil then return end
	if LWF4.__internal.table_count(LWF4.mem.EventRegistry[ e.DESCR ]) > 0 then
		local args = {
			[1] = arg1,   [2] = arg2,   [3] = arg3,   [4] = arg4,   [5] = arg5,
			[6] = arg6,   [7] = arg7,   [8] = arg8,   [9] = arg9,   [10] = arg10,
			[11] = arg11, [12] = arg12, [13] = arg13, [14] = arg14, [15] = arg15,
			[16] = arg16, [17] = arg17, [18] = arg18, [19] = arg19, [20] = arg20,
		}
		for k,a in pairs(LWF4.mem.EventRegistry[ e.DESCR ]) do
			if a ~= nil then
				if a.Handler ~= nil then
					if a.TableParms then
						local parms = {}
						if e.PARAMS ~= nil then
							for _,parm in pairs ( e.PARAMS ) do
								parms[ parm.name ] = args[ parm.paramNum ]
							end
							a.Handler( parms )
						end
					else
						a.Handler( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11
							, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 )
					end
				end
			end
		end
	end
end
lwf4.__load = function( eventCode, addOnName )
	if not LWF4 then return end
	if LWF4.mem.Addons[addOnName] then
		local base = LWF4.mem.Addons[addOnName].__base
		if base then
			if not LWF4.mem.AddonState[addOnName] then LWF4.mem.AddonState[addOnName] = {} end
			--base.Ready = true
			if not LWF4.mem.AddonState[addOnName].Started then
				LWF4.mem.AddonState[addOnName].Loaded = true
				LWF4.mem.AddonState[addOnName].Started = true
				LWF4.__extension.PrepSettings( base )
				if base.onBeforeStartupCallback then base:onBeforeStartupCallback() end
				if base.onStartupCallback then base:onStartupCallback() end
				if base.onAfterStartupCallback then base:onAfterStartupCallback() end
			end
		end
	end
end

lwf4.REGISTER_FACTORY = function( self, addonLoadedIndependently, enableFrameworkOnUpdate, onBeforeStartupCallback, onStartupCallback, onAfterStartupCallback, globalSettingsVariable, useAdvancedSettings )
	if not self or not LWF4 then return end
	if self.ID == nil and self.Name ~= nil then self.ID = self.Name end

	self.__settingsVar = globalSettingsVariable
	self.__AdvancedSettingsEnabled = useAdvancedSettings

	self.addonLoadedIndependently 	= addonLoadedIndependently
	self.enableFrameworkOnUpdate 	= enableFrameworkOnUpdate
	self.onBeforeStartupCallback 	= onBeforeStartupCallback
	self.onStartupCallback 			= onStartupCallback
	self.onAfterStartupCallback 	= onAfterStartupCallback

	self.GLOBAL 					= LWF4.data
	self.Frames						= LWF4.UI

	-- STANDARD API
	self.BufferPause 			= LWF4.__extension.BufferPause
	self.comma_number 			= LWF4.__extension.comma_number
	self.Descr 					= LWF4.__extension.Descr
	self.DumpCommandsToChat 	= LWF4.__extension.DumpCommandsToChat
	self.DumpWindowName 		= LWF4.__extension.DumpWindowName
	self.DumpWindowsToChat 		= LWF4.__extension.DumpWindowsToChat
	self.EventName 				= LWF4.__extension.EventName
	self.FindFrame				= LWF4.__extension.FindFrame
	self.FindGameImage 			= LWF4.__extension.FindGameImage
	self.GetDateTimeString 		= LWF4.__extension.GetDateTimeString
	self.GetOrDefault 			= LWF4.__extension.GetOrDefault
	self.GuildName 				= LWF4.__extension.GuildName
	self.Indent 				= LWF4.__extension.Indent
	self.InjectAdvancedSettings	= LWF4.__extension.InjectAdvancedSettings
	self.LoadEmotes				= LWF4.__extension.LoadEmotes
	self.MakeList				= LWF4.__extension.MakeList
	self.MakeStandardLAMOption 	= LWF4.__extension.MakeStandardLAMOption
	self.MakeStandardLAMPanel 	= LWF4.__extension.MakeStandardLAMPanel
	self.MillisecondsToHuman 	= LWF4.__extension.MillisecondsToHuman
	self.PairsByKeys 			= LWF4.__extension.PairsByKeys
	self.PlaySound				= LWF4.__extension.PlaySound
	self.PrepPlayerName 		= LWF4.__extension.PrepPlayerName
	self.PrepSettings 			= LWF4.__extension.PrepSettings
	self.Print 					= LWF4.__extension.Print
	self.RedGreenPowerMeter 	= LWF4.__extension.RedGreenPowerMeter
	self.Round 					= LWF4.__extension.Round
	self.ReloadUI				= LWF4.__extension.ReloadUI
	self.string_endswith		= LWF4.__extension.string_endswith
	self.string_split 			= LWF4.__extension.string_split
	self.string_startswith		= LWF4.__extension.string_startswith
	self.string_trim 			= LWF4.__extension.string_trim
	self.table_count 			= LWF4.__extension.table_count
	self.table_next 			= LWF4.__extension.table_next
	self.table_remove 			= LWF4.__extension.table_remove
	self.Tic 					= LWF4.__extension.Tic
	self.ToggleEvent 			= LWF4.__extension.ToggleEvent
	self.ToggleSlashCommand 	= LWF4.__extension.ToggleSlashCommand
	self.ToggleUIFrames 		= LWF4.__extension.ToggleUIFrames
	self.UniqueName 			= LWF4.__extension.UniqueName

	-- ALTERNATIVE API // BACKWARDS COMPATIBLE
	self.MakeStandardOption 				= LWF4.__extension.MakeStandardLAMOption
	self.MakeStandardSettingsPanel 			= LWF4.__extension.MakeStandardLAMPanel
	self.table_findRemove					= LWF4.__extension.table_remove
	self.comma_value						= LWF4.__extension.comma_number
	self.GetMillisecondsToHuman				= LWF4.__extension.MillisecondsToHuman
	self.GetGameImage						= LWF4.__extension.FindGameImage
	self.GetColorScale_RedGreenPowerMeter	= LWF4.__extension.RedGreenPowerMeter
	self.GetCountOf 						= LWF4.__extension.table_count
	self.GetNextOf 							= LWF4.__extension.table_next
	self.DeriveGuildName 					= LWF4.__extension.GuildName
	self.EndsWith							= LWF4.__extension.string_endswith
	self.trim 								= LWF4.__extension.string_trim
	self.split 								= LWF4.__extension.string_split
	self.StartsWith							= LWF4.__extension.string_startswith
	self.OnUpdateCallback					= LWF4.__extension.Tic
	self.SlashCommand						= LWF4.__extension.ToggleSlashCommand

	-- TOGGLE API HOOKS
	self.RegisterEvent			= function( self, EventToWatch, Callback, ParamsAsTable ) LWF4.__extension.ToggleEvent( self, EventToWatch, Callback, ParamsAsTable ) end
	self.UnregisterEvent		= function( self, EventToWatch ) LWF4.__extension.ToggleEvent( self, EventToWatch ) end
	self.SlashCommand_Add		= function( self, Command, Callback ) LWF4.__extension.ToggleSlashCommand( self, Command, Callback ) end
	self.SlashCommand_Remove	= function( self, Command ) LWF4.__extension.ToggleSlashCommand( self, Command ) end

	-- EXTRAS
	self.__DumpEventRegistry = function() LWF4.__internal.Print( LWF4.mem.EventRegistry ) end
	self.LAM = LWF4.LAM

	if not LWF4.mem.Addons then LWF4.mem.Addons = {} end
	if not LWF4.mem.Addons[self.Name] then LWF4.mem.Addons[self.Name] = {} end
	LWF4.mem.Addons[self.Name].__base = self
	self.__index = self
end

local startup = function()
	LWF4.__hydrate(); LWF4.__internalize(); LWF4.__extend(); LWF4.__struct(); LWF4.__register();
	EVENT_MANAGER:UnregisterForEvent( "LWF4_StartUp", EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:UnregisterForEvent( "LWF4_Branding", EVENT_PLAYER_ACTIVATED )
	EVENT_MANAGER:RegisterForEvent( "LWF4_StartUp", EVENT_ADD_ON_LOADED, LWF4.__load )
	EVENT_MANAGER:RegisterForEvent( "LWF4_Branding", EVENT_PLAYER_ACTIVATED, function()
		LWF4.__PlayerActivated = true
		--if not LWF4.SILENCE then LWF4.__internal.Print( "|c990000You are now WYKKYD GAMING with us!|r |c808080[ Official LibWykkydFactory "..LWF4.version.." ]|r" ) end
		EVENT_MANAGER:UnregisterForEvent( "LWF4_Branding", EVENT_PLAYER_ACTIVATED )
	end)
end

if lwf4.libStub then
	if not LWF4 then
		LWF4 = lwf4; startup()
	else
		if LWF4._v.major < lwf4._v.major
		or (
			LWF4._v.monthly < lwf4._v.monthly
			or ( LWF4._v.monthly == lwf4._v.monthly and LWF4._v.daily <= lwf4._v.daily )
			or ( LWF4._v.monthly == lwf4._v.monthly and LWF4._v.daily == lwf4._v.daily and LWF4._v.minor < lwf4._v.minor )
		) then
			LWF4._v = lwf4._v
			LWF4.__internal = lwf4.__internal
			LWF4.__extension = lwf4.__extension
			LWF4.data = lwf4.data
			LWF4.UI = lwf4.UI
			LWF4.REGISTER_FACTORY = lwf4.REGISTER_FACTORY
			startup()
		end
	end
end
