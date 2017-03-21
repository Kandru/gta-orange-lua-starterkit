-- LUA-Starterkit GTA5 (GTA-Orange.net)
-- Maintained by Karl-Martin Minkner (https://github.com/Kandru/gta-orange-lua-starterkit, https://kandru.net)
-- Feel free to modify but do NOT delete this copyright

Player:On('command', function(pl, cmd, params)
	cmd = cmd:lower()
    if cmd == 'wea' then
		if #params == 1 then
			Player:TriggerClient('lsk_changeWeather', params[1])
		end
	end
end