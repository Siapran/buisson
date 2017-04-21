local sql = require("sqlite3")

local conn = sql.open("buisson.db")

local function init_db( )
	local t, n =
		conn:exec("select name from sqlite_master where type = 'table'")
	if n ~= 2 then
		os.execute("sqlite3 buisson.db < create.sql")
	end
end

local function transfer( source, destination, amount, label )
	local stmt = conn:prepare("insert into transactions (transaction_amount, transaction_label, transaction_source, transaction_destination) values(?, ?, ?, ?)")
	stmt:reset():bind(amount, label, source, destination):step()
	stmt:close()
	print("Transferred " .. amount .. " from " .. (source or "NULL") .. " to " .. (destination or "NULL") .. (label and (" : " .. label) or ""))
end

local function deposit( destination, amount, label )
	transfer(nil, destination, amount, label)
end

local function withdraw( source, amount, label )
	transfer(source, nil, amount, label)
end

local function new_user( id, name, balance )
	local stmt = conn:prepare("insert into accounts values(?, ?, ?)")
	stmt:reset():bind(id, name, 0):step()
	stmt:close()
	print("Created account " .. name .. " with id " .. (id or "NULL"))
	deposit(id, balance, "Initial balance")
end

local function query( statement )
	return coroutine.wrap(function ()
		local stmt = conn:prepare(statement)
		local row, names = stmt:step({}, {})
		repeat
			local res = {}
			for i,v in ipairs(names) do
				local elem = row[i]
				res[i] = elem
				res[v] = elem
			end
			coroutine.yield(res)
		until not stmt:step(row)
		stmt:close()
		return nil
	end)
end

local function get_transactions( )
	local res = {}
	for row in query("select * from transactions") do
		res[#res + 1] = row
	end
	return res
end

local function get_accounts( )
	local res = {}
	for row in query("select * from accounts") do
		res[#res + 1] = row
	end
	return res
end

init_db()

new_user(1, "Siapran", 100)
new_user(2, "Bellerm", 100)
deposit(1, 50)
transfer(1, 2, 75)
withdraw(2, 25)
for _,row in ipairs(get_accounts()) do
	print("Account:", row.account_id, row.account_name, row.account_balance)
end
for _,row in ipairs(get_transactions()) do
	print("Transaction:",
		row.transaction_id,
		row.transaction_amount,
		row.transaction_label,
		row.transaction_source,
		row.transaction_destination,
		row.transaction_datetime)
end

local package = {
	transfer = transfer,
	deposit = deposit,
	withdraw = withdraw,
	new_user = new_user,
	query = query,
	get_transactions = get_transactions,
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
