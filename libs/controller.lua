local template = require("resty/template")
local mime = require("mime")
local json = require("json")
local parse_query = require('querystring').parse
local api = require("api")
local pages = require("pages")

-- local bundle = require('luvi').bundle
-- local fs = {}
-- function fs.stat(path)
-- 	return bundle.stat(path)
-- end

template.caching(false)

local function page_get ( req, res, go )
	local page = pages.page(req, req.path)
	if not page then
		return go()
	end
	res.body = tostring(page)
	res.code = 200
	res.headers["Content-Type"] = mime.getType("html")
end

local function not_found( req, res )
	res.body = tostring(pages.page(req, 404))
	res.code = 404
	res.headers["Content-Type"] = mime.getType("html")
end

local function view_get( req, res, go )
	-- p(req.params.path)
	local view = pages.view(req, "/" .. req.params.path)
	if not view then
		return
	end
	res.body = tostring(view)
	res.code = 200
	res.headers["Content-Type"] = mime.getType("html")
end

local function api_post ( req, res )
	local api_request = api.POST[req.params.name]
	-- p(req.body)
	local query = parse_query(req.body)
	-- p(query)
	if api_request then
		api_request(query)
		res.code = 302
		res.headers.Location = "/"
	end
end

local function api_get ( req, res )
	local api_request = api.GET[req.params.name] -- or api.POST[req.params.name]
	-- p(req.query)
	if api_request then
		res.body = json.stringify(api_request(req.query))
		res.code = 200
		res.headers["Content-Type"] = mime.getType("json")
	end
end

return {
	page_get = page_get,
	view_get = view_get,
	api_post = api_post,
	api_get = api_get,
	not_found = not_found
}
