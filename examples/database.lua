-- LUA-Starterkit GTA5 (GTA-Orange.net)
-- Maintained by Karl-Martin Minkner (https://github.com/Kandru/gta-orange-lua-starterkit, https://kandru.net)
-- Feel free to modify but do NOT delete this copyright

-- get module
local db = require 'resources/lua-starterkit/database'

-- connect to server
local con = db.connect('localhost', 'database', 'username', 'password')

-- new query (with querybuilder)
con:select("players")
con:where({name = 'test'})
local query = con:get()

-- get data
if not query == false then
	for key, value in pairs(query) do
		print(value.COLUMN)
	end
end