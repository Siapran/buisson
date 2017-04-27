local api = require("api")
local template = require("resty/template")

local pages = {}
local function add_page( path, page )
	page.path = path
	pages[path] = page
end

add_page(404, {name = "404", view = "html/view/404.html"})
add_page("/", {name = "Home", view = "html/view/home.html"})

add_page("/transactions", {
	name = "Transactions",
	view = "html/view/transactions.html",
	context = function ()
		return {
			accounts = api.GET.accounts(),
			transactions = api.GET.transactions()
		}
	end
})

-- add_page("/workshop", {name = "Atelier"})

local navigation = {
	pages["/"],
	pages["/transactions"],
	-- pages["/workshop"],
}

return function ( req, path )
	local page = pages[path]
	if not page then return end
	local layout = template.new("html/layout.html")

	layout.method = req.method
	layout.path = req.path
	layout.nav = navigation

	p("REACHED", page)

	layout.view = template.compile(page.view)(page.context
		and (type(page.context) == "table" and page.context
		or type(page.context) == "function" and page.context(req, path)))

	return layout
end
