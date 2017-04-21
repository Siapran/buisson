local database = require("database")
local transfer = database.transfer
local query = database.query
local table_query = database.table_query

local function deposit( destination, amount, label )
	transfer(nil, destination, amount, label)
end

local function withdraw( source, amount, label )
	transfer(source, nil, amount, label)
end

local function get_transactions( )
	return table_query("select * from transactions")
end

local function get_accounts( )
	return table_query(("select * from accounts"))
end

local package = {
	GET = {
		accounts = get_accounts,
		transactions = get_transactions,
	},
	POST = {
		deposit = deposit,
		withdraw = withdraw,
		transfer = transfer,
		user = database.create_user,
	}
}

return package