-- utils
function string:startswith( str )
	return self:sub(1, #str) == str
end
function string:endswith( str )
	return self:sub(-#str) == str
end
local function add_all( table, other )
	local len = #table
	for i,v in ipairs(other) do
		table[len + i] = v
	end
end

local concat = table.concat
local unpack = table.unpack
local select = select

local function query_builder( table, fields, filters )
	local query = "select " .. concat(fields, ", ") .. " from "
	.. table .. " where "
	local subqueries = {}
	local binds = {}
	for _,filter in ipairs(filters) do
		local subquery, bind = filter()
		if subquery then
			subqueries[#subqueries + 1] = subquery
			add_all(binds, bind)
		end
	end
	query = query .. concat(subqueries, " and ")
	return query, binds
end

local comparators = {"=", "<", ">", "<=", ">=", "!="}

local function field_comparator( field, arg, validator )
	validator = validator or tonumber
	return function( )
		local comparator = "="
		local bind = validator(arg)
		if not bind then
			for _,v in ipairs(comparators) do
				if arg:startswith(v) then
					comparator = v
					arg = arg:sub(#v + 1)
					break
				end
			end
			bind = validator(arg)
			if not bind then return end
		end
		return field .. " " .. comparator .. " ?", {bind}
	end
end

local function name_interpolator( field, arg )
	local query
	if type(arg) == "string" then
		query = field .. " in (select account_id from account where account_name like ?)"
		return query, "%" .. arg .. "%"
	else
		local comparator, id = compare_parser(arg)
		if not comparator then return end
		query = field .. " " .. comparator .. " ?"
		return query, id
	end
end

local search_filters = setmetatable({}, {
	__index = function ( self, key )
		return function ( table, arg )
			
		end
	end
})


function search_filters.source( table, arg )
	if table ~= "transaction" then return end
	return name_interpolator("transaction_source", arg)
end

function search_filters.source( table, arg )
	if table ~= "transaction" then return end
	return name_interpolator("transaction_destination", arg)
end

function parse_search( table, search_string )
	-- body
end
