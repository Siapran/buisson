local database = require("database")
local raw_transfer = database.transfer
local query = database.query
local table_query = database.table_query
local type = type

local function bind_param( key_list, func )
	return function ( value_map )
		if not value_map then return func() end
		local params = {}
		local param
		for index, key in ipairs(key_list) do
			if type(key) == table then
				param = key[1]
			else
				param = value_map[key]
			end
			params[index] = param
		end
		return func(unpack(params))
	end
end

local create_user = bind_param({"id", "name", "balance"}, database.create_user)

local transfer = bind_param({"source", "destination", "amount", "label"}, raw_transfer)

local deposit = bind_param({{nil}, "destination", "amount", "label"}, raw_transfer)

local withdraw = bind_param({"source", {nil}, "amount", "label"}, raw_transfer)

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
		user = create_user,
	}
}

return package
