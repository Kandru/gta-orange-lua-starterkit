-- LUA-Starterkit GTA5 (GTA-Orange.net)
-- Maintained by Karl-Martin Minkner (https://github.com/Kandru/gta-orange-lua-starterkit, https://kandru.net)
-- Feel free to modify but do NOT delete this copyright

local database = {
	conn = nil,
	bquery = '',
	b_countwhere = 0
}

database.__env = __orange__.SQLEnv()

if not database.__env then
	print('database: error loading mysql library')
else
	database.__env = database.__env.mysql()
end

--
-- connect to mysql database
--
function database.connect(host, db, user, pass)
	local _host = string.split(host, ':')
	database.conn = database.__env:connect(db, user, pass, _host[1], _host[2])
	if not database.conn then
		print('database: error connecting to database')
		return false
	else
		print('database: connection successful')
		return true
	end
end

--
-- close connection to mysql database
--
function database.close()
	if database.conn then database.conn:close() end
end

--
-- check if connection to database was successful
--
function database.connected()
	if database.conn then
		return true
	else
		return false
	end
end

--
-- low level query function (shouldn't be used outside this class)
--
function database.doQuery(query, ...)
	if database.conn then
		local _r = database.conn:execute(string.format(query, database.escape(database.conn, ...)))

		if type(_r) == 'userdata' then
			local res = {}

			local row = _r:fetch({}, 'a')
			while row do
				local ent = {} for k, v in pairs(row) do ent[k] = v end
				table.insert(res, ent)
				row = _r:fetch(row, 'a')
			end
			_r:close()

			return res
		elseif type(_r) == 'number' then
			return _r
		else
			print('database: '..type(_r)..' (got unkown data)')
			return {}
		end
	else
		print('database: connection closed')
		return {}
	end
end

--
-- database query function (should be used outside this class)
--
function database.query(query, ...)
	local next = next
	local type = type
	local tmp = database.doQuery(query, ...)
	if (type(tmp) ~= 'number' and next(tmp) == nil) then
		return false
	elseif type(tmp) == 'number' then
		if tmp == 1 then
			return true
		else
			return false
		end
	else
		return tmp
	end
end

--
-- select data from a table
--
function database.select(tablename, columns)
	if not columns then
		database.bquery = 'SELECT * FROM '..database.escape(database.conn,tablename)
	else
		database.bquery = 'SELECT '
		for value in columns do
			database.bquery = database.bquery..value..','
		end
		-- delete last comma
		database.bquery = database.bquery:sub(1, -2)
	end
end

--
-- update data from a table
--
function database.update(tablename, columns, where)
	local count_where = 0
	database.bquery = 'UPDATE '..database.escape(database.conn,tablename)..' SET '
	for key, value in pairs(columns) do
		database.bquery = database.bquery..key..'="'..database.escape(database.conn,value)..'",'
	end
	-- delete last comma
	database.bquery = database.bquery:sub(1, -2)
	if where then
		database.bquery = database.bquery..' WHERE '
		for key, value in pairs(where) do
			if count_where > 0 then
				database.bquery = database.bquery..' and '
			end
			database.bquery = database.bquery..key..'="'..database.escape(database.conn,value)..'"'
		end
	end
	return database.query(database.bquery)
end

--
-- insert data in a table
--
function database.insert(tablename, columns, entries)
	database.bquery = 'INSERT INTO '..database.escape(database.conn,tablename)..' ('
	for key, value in ipairs(columns) do
		database.bquery = database.bquery..value..','
	end
	-- delete last comma
	database.bquery = database.bquery:sub(1, -2)..')VALUES'
	for key, value in ipairs(entries) do
		database.bquery = database.bquery..'('
		for key2, value2 in ipairs(value) do
			database.bquery = database.bquery..'"'..value2..'",'
		end
		database.bquery = database.bquery:sub(1, -2)
		database.bquery = database.bquery..')'
	end
	return database.query(database.bquery)
end

--
-- and_where logic
--
function database.and_where(where)
	for key, value in pairs(where) do
		if database.b_countwhere == 0 then
			database.bquery = database.bquery..' WHERE '..key..'="'..database.escape(database.conn,value)..'"'
			database.b_countwhere = database.b_countwhere + 1
		else
			database.bquery = database.bquery..' and '..key..'="'..database.escape(database.conn,value)..'"'
		end
	end
end

--
-- where logic (alias for end_where logic)
--
function database.where(where)
	database.and_where(where)
end

--
-- or where logic
--
function database.or_where(where)
	for key, value in pairs(where) do
		if database.b_countwhere == 0 then
			database.bquery = database.bquery..' WHERE '..key..'="'..database.escape(database.conn,value)..'"'
			database.b_countwhere = database.b_countwhere + 1
		else
			database.bquery = database.bquery..' or '..key..'="'..database.escape(database.conn,value)..'"'
		end
	end
end

--
-- get data built with query builder
--
function database.get(limit, offset)
	local result = false
	if not limit then
		result = database.query(database.bquery)
	else
		if not offset then
			offset = 0
		end
		result = database.query(database.bquery..' LIMIT %i,%i',offset,limit)
	end
	database.bquery = ''
	database.b_countwhere = 0
	return result
end

--
-- escape database input (not neccessary needed outside this class. database class will perform escape options itself)
--
function database.escape(conn, ...)
	local res = {}

	for k, v in pairs({ ... }) do
		table.insert(res, conn:escape(v))
	end

	return unpack(res)
end

return database