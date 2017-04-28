local api = require("api")
local template = require("resty/template")

local views = {}
local function add_view( path, view )
	view.path = path
	views[path] = view
end

local forms = {
	{path = "/form/create_user", label = "Ajouter un compte"}, 
	{path = "/form/transfer", label = "Transférer de l'argent"}, 
	{path = "/form/deposit", label = "Déposer de l'argent"}, 
	{path = "/form/withdraw", label = "Retirer de l'argent"}
}
for _,form in ipairs(forms) do
	add_view(form.path, {
		view = "html" .. form.path .. ".html",
		context = function ()
			return {
				accounts = api.GET.accounts()
			}
		end
	})
end

add_view(404, {name = "404", view = "html/view/404.html"})

add_view("/", {
	name = "Home",
	view = "html/view/home.html",
	-- icon = "/static/img/parchment-inverse.svg",
})

add_view("/accounting", {
	name = "Comptabilité",
	view = "html/view/accounting.html",
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

local function make_view( req, path )
	local view = views[path]
	if not view then return end
	return template.compile(view.view)(view.context
			and (type(view.context) == "table" and view.context
			or type(view.context) == "function" and view.context(req, path)))
end

local function make_page( req, path )
	local view = make_view(req, path)
	if not view then return end

	local layout = template.new("html/layout.html")

	layout.method = req.method
	layout.path = req.path
	layout.nav = navigation

	layout.view = view

	return layout
end

return {
	page = make_page,
	view = make_view,
}
