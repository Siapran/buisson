local api = require("api")
local template = require("resty/template")

local views = {}
local function add_view( path, view )
	view.path = path
	views[path] = view
end

local forms = {
	{name = "create_user", label = "Ajouter un compte"}, 
	{name = "transfer", label = "Transférer de l'argent"}, 
	{name = "deposit", label = "Déposer de l'argent"}, 
	{name = "withdraw", label = "Retirer de l'argent"}
}
for _,form in ipairs(forms) do
	form.path = "/form/" .. form.name
	add_view(form.path, {
		html = "html" .. form.path .. ".html",
		context = function ()
			return {
				accounts = api.GET.accounts()
			}
		end
	})
end

add_view(404, {name = "404", html = "html/view/404.html"})

add_view("/", {
	name = "Home",
	html = "html/view/home.html",
	-- icon = "/static/img/parchment-inverse.svg",
})

add_view("/accounting", {
	name = "Comptabilité",
	html = "html/view/accounting.html",
	-- icon = "/static/img/coins-inverse.svg",
	context = function ()
		return {
			accounts = api.GET.accounts(),
			transactions = api.GET.transactions(),
			actions = forms,
		}
	end
})

-- add_view("/workshop", {name = "Atelier"})

local navigation = {
	views["/"],
	views["/accounting"],
	-- views["/workshop"],
}

local function view_context( view )
	return view.context
		and (type(view.context) == "table" and view.context
		or type(view.context) == "function" and view.context(req, path))
end

local function make_view( req, path )
	local view = views[path]
	if not view then return end
	local res = template.new(view.html)
	for k,v in pairs(view_context(view)) do
		res[k] = v
	end
	return res
end

local function make_page( req, path )
	local view = views[path]
	if not view then return end

	local page = template.new(view.html, "html/layout.html")

	page.method = req.method
	page.path = req.path
	page.nav = navigation

	for k,v in pairs(view_context(view)) do
		page[k] = v
	end

	return page
end

return {
	page = make_page,
	view = make_view,
}
