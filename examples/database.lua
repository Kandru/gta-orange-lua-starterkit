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
con:and_where({name = 'test'})
con:or_where({name = 'test'})
local query = con:get()

-- new query (without querybuilder)
local query = con:query("SELECT * FROM players WHERE name='%s'", 'test')

-- get data
if not query == false then
	for key, value in pairs(query) do
		print(value.COLUMN)
	end
end

-- hint: query will be "false" if result is empty. query will also be "false" if an sql query error happened

-- insert new row(s)
local query = con:insert('players', {'name'}, {{'Player 1'}, {'Player 2'}})

-- update row
local query = con:update('players', {name = 'FooBar'}, {name = 'Player 1'})