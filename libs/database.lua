local sql = require("sqlite")
local type = type
local tonumber = tonumber

local conn


local function init_db( )
	conn = sql.open("db/buisson.db")
	conn:exec("PRAGMA foreign_keys = ON;")
	local t, n =
		conn:exec("select name from sqlite_master where type = 'table'")
	if n ~= 2 then
		print("No valid database present")
		os.execute("sqlite3 db/buisson.db < db/create.sql")
		print("Initialized database")
	end
end

local function query( statement, bindlist, mode )
	mode = mode or "k"
	local indexes = mode:match("i")
	local keys = mode:match("k")
	return coroutine.wrap(function ()
		local stmt = conn:prepare(statement)
		if bindlist then stmt:reset():bind(unpack(bindlist)) end
		local row, names = stmt:step({}, {})
		if not names then return nil end
		repeat
			local res = {}
			for i,v in ipairs(names) do
				local elem = row[i]
				-- try to convert 64bit ints
				if type(elem) == "cdata" then
					elem = tonumber(elem) or elem
				end
				if keys then res[v] = elem end
				if indexes then res[i] = elem end
			end
			coroutine.yield(res)
		until not stmt:step(row)
		stmt:close()
		return nil
	end)
end

local function table_query( statement, bindlist, mode )
	local res = {}
	for row in query(statement, bindlist, mode) do
		res[#res + 1] = row
	end
	return res
end

local function transfer( source, destination, amount, label )
	local stmt = conn:prepare("insert into transactions (transaction_amount, transaction_label, transaction_source, transaction_destination) values(?, ?, ?, ?)")
	stmt:reset():bind(amount, label, source, destination):step()
	stmt:close()
	print("Transferred " .. amount .. " from " .. (source or "NULL") .. " to " .. (destination or "NULL") .. (label and (" : " .. label) or ""))
end

local function create_user( id, name, balance )
	local stmt = conn:prepare("insert into accounts values(?, ?, ?)")
	stmt:reset():bind(id, name, 0):step()
	stmt:close()
	print("Created account " .. name .. " with id " .. (id or "NULL"))
	if balance and balance ~= 0 then
		transfer(nil, id, balance, "Initial balance")
	end
end

init_db()

local package = {
	transfer = transfer,
	create_user = create_user,
	query = query,
	table_query = table_query,
}

return package

-- create table if not exists accounts (
-- 	account_id integer primary key,
-- 	account_name text not null,
-- 	account_balance integer default 0
-- );

-- create table if not exists transactions (
-- 	transaction_id integer primary key,
-- 	transaction_amount integer not null,
-- 	transaction_label text,
-- 	transaction_source integer references accounts (account_id),
-- 	transaction_destination integer references accounts (account_id),
-- 	transaction_datetime integer
-- 	check(transaction_source != 1000 and transaction_destination != 1000)
-- 	check(transaction_source != transaction_destination)
-- );

-- insert into accounts (account_id, account_name, account_balance)
-- 	values (1000, "Reserves", 0);
-- insert into accounts (account_id, account_name, account_balance)
-- 	values (1001, "Capital", 0);
