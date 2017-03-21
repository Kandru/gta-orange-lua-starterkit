-- LUA-Starterkit GTA5 (GTA-Orange.net)
-- Maintained by Karl-Martin Minkner (https://github.com/Kandru/gta-orange-lua-starterkit, https://kandru.net)
-- Feel free to modify but do NOT delete this copyright

Server:On('lsk_changeWeather', function(weather)
	if weather == '0' then
		weather = "Extra Sunny"
	elseif weather == '1' then
		weather = "Clear"
	elseif weather == '2' then
		weather = "Clouds"
	elseif weather == '3' then
		weather = "Smog"
	elseif weather == '4' then
		weather = "Foggy"
	elseif weather == '5' then
		weather = "Overcast"
	elseif weather == '6' then
		weather = "Rain"
	elseif weather == '7' then
		weather = "Thunder"
	elseif weather == '8' then
		weather = "Light rain"
	elseif weather == '9' then
		weather = "Smoggy light rain"
	elseif weather == '10' then
		weather = "Very light snow"
	elseif weather == '11' then
		weather = "Windy light snow"
	elseif weather == '12' then
		weather = "Light snow"
	else
		weather = "Clear"
	end
	Native.SetWeatherTypeNowPersist(weather)
	Native.SetWeatherTypeNow(weather)
	Native.SetOverrideWeather(weather)
	Native.SetWeatherTypePersist(weather)
end)