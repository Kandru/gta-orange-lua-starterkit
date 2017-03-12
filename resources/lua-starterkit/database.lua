-- LUA-Starterkit GTA5 (GTA-Orange.net)
-- Maintained by Karl-Martin Minkner (https://github.com/Kandru/gta-orange-lua-starterkit, https://kandru.net)
-- Feel free to modify but do NOT delete this copyright

local database = {}

database.__env = __orange__.SQLEnv()
if not database.__env then
	print('database: error loading mysql library')
else
	database.__env = database.__env.mysql()
end

function database.init(conn)
	local obj = {}
	obj.__conn = conn
	obj.bquery = ''
	obj.b_countwhere = 0
	
	if not conn then
		print('database: error connecting to database')
	else
		print('database: connection successful')
	end

    function obj:close()
        if self.__conn then self.__conn:close() end
    end
	
	function obj:connected()
		if self.__conn then
			return true
		else
			return false
		end
	end

    function obj:noQuery(query, ...)
		if self.__conn then
			self.__conn:execute(string.format(query, database.escape(self.__conn, ...)))
		else print('database: connection closed') end
	end

	function obj:doQuery(query, ...)
		if self.__conn then
			local _r = self.__conn:execute(string.format(query, database.escape(self.__conn, ...)))

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
				print('database: '..type(_r))
				return {}
			end
		else
			print('database: connection closed')
			return {}
		end
	end
	
	function obj:query(query, ...)
		local next = next
		local type = type
		local tmp = self:doQuery(query, ...)
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
	
	function obj:select(tablename, columns)
		if not columns then
			self.bquery = 'SELECT * FROM '..database.escape(self.__conn,tablename)
		else
			self.bquery = 'SELECT '
			for value in columns do
				self.bquery = self.bquery..value..','
			end
			-- delete last comma
			self.bquery = self.bquery:sub(1, -2)
		end
	end
	
	function obj:update(tablename, columns, where)
		local count_where = 0
		self.bquery = 'UPDATE '..database.escape(self.__conn,tablename)..' SET '
		for key, value in pairs(columns) do
			self.bquery = self.bquery..key..'="'..database.escape(self.__conn,value)..'",'
		end
		-- delete last comma
		self.bquery = self.bquery:sub(1, -2)
		if where then
			self.bquery = self.bquery..' WHERE '
			for key, value in pairs(where) do
				if count_where > 0 then
					self.bquery = self.bquery..' and '
				end
				self.bquery = self.bquery..key..'="'..database.escape(self.__conn,value)..'"'
			end
		end
		return self:query(self.bquery)
	end
	
	function obj:insert(tablename, columns, entries)
		self.bquery = 'INSERT INTO '..database.escape(self.__conn,tablename)..' ('
		for key, value in ipairs(columns) do
			self.bquery = self.bquery..value..','
		end
		-- delete last comma
		self.bquery = self.bquery:sub(1, -2)..')VALUES'
		for key, value in ipairs(entries) do
			self.bquery = self.bquery..'('
			for key2, value2 in ipairs(value) do
				self.bquery = self.bquery..'"'..value2..'",'
			end
			self.bquery = self.bquery:sub(1, -2)
			self.bquery = self.bquery..')'
		end
		return self:query(self.bquery)
	end
	
	function obj:and_where(where)
		for key, value in pairs(where) do
			if self.b_countwhere == 0 then
				self.bquery = self.bquery..' WHERE '..key..'="'..database.escape(self.__conn,value)..'"'
				self.b_countwhere = self.b_countwhere + 1
			else
				self.bquery = self.bquery..' and '..key..'="'..database.escape(self.__conn,value)..'"'
			end
		end
	end
	
	function obj:where(where)
		self:and_where(where)
	end
	
	function obj:or_where(where)
		for key, value in pairs(where) do
			if self.b_countwhere == 0 then
				self.bquery = self.bquery..' WHERE '..key..'="'..database.escape(self.__conn,value)..'"'
				self.b_countwhere = self.b_countwhere + 1
			else
				self.bquery = self.bquery..' or '..key..'="'..database.escape(self.__conn,value)..'"'
			end
		end
	end
	
	function obj:get(limit, offset)
		if not limit then
			return self:query(self.bquery)
		else
			if not offset then
				offset = 0
			end
			return self:query(self.bquery..' LIMIT %i,%i',offset,limit)
		end
	end
	
    return obj
end

function database.connect(host, db, user, pass)
	local _host = string.split(host, ':')
	local _pass

	return database.init(database.__env:connect(db, user, _pass, _host[1], _host[2]))
end

function database.escape(conn, ...)
	local res = {}

	for k, v in pairs({ ... }) do
		table.insert(res, conn:escape(v))
	end

	return unpack(res)
end

return database