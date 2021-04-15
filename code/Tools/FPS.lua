local _addon = WYK_Toolbar

_addon.Feature.Toolbar.GetFramesPerSecond = function()
	local onOff = _addon:GetOrDefault( true, _addon.Settings["fps_enabled"])
  local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	local fpsLow = tonumber(_addon:GetOrDefault( 15, _addon.Settings["fps_low"]))
	local fpsMid = tonumber(_addon:GetOrDefault( 22, _addon.Settings["fps_mid"]))
	local c = {215/255,213/255,205/255,1}
	local framerate = GetFramerate()
	if framerate <= fpsMid and framerate > fpsLow then c = {1,1,0,1}
	elseif framerate <= fpsLow then c = {1,.5,0,1} end
    
  if useWhiteText then c = {1,1,1,1}; end
  
	return _addon._DefaultLabelColor .. "FPS:|r "..math.floor(framerate), c
end

_addon.Feature.Toolbar.GetLatency = function()
	local onOff = _addon:GetOrDefault( true, _addon.Settings["latency_enabled"])
	local latHigh = tonumber(_addon:GetOrDefault( 300, _addon.Settings["latency_high"]))
	local latMid = tonumber(_addon:GetOrDefault( 150, _addon.Settings["latency_mid"]))
  local useWhiteText = _addon:GetOrDefault( false, _addon.Settings["white_text"] )
	--local c = {215/255,213/255,205/255,1}
	local c = {.5,1,0,1}   --green
	local latency = GetLatency()	
	if latency < latMid then c = {.5,1,0,1}  --green	
	elseif latency >= latMid and latency < latHigh then c = {1,1,0,1}  --yellow
	elseif latency >= latHigh then c = {1,.5,0,1} end   --orange
    
  if useWhiteText then c = {1,1,1,1}; end

	return _addon._DefaultLabelColor .. "PR:|r "..math.floor(latency), c
end