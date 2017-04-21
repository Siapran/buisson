local weblit = require("weblit")
local template = require("resty/template")
local mime = require("mime")
local json = require("json")
local api = require("api")
local parse_query = require('querystring').parse

weblit.app

	.bind({
		host = "127.0.0.1",
		port = 8080
	})

	.bind({
		host = "0.0.0.0",
		port = 4269
	})

	-- Configure weblit server
	.use(weblit.logger)
	.use(weblit.autoHeaders)
	-- .use(weblit.etagCache)
	.use(weblit.cors)

	.route({
		path = "/static/:path:"
	}, weblit.static("./static/"))

	-- A custom route that sends back method and part of url.
	.route({
		path = "/",
		method = "GET"
	}, function (req, res)
		local file = "html/index.html"
		res.body = template.compile(file)({
			method = req.method,
			path = req.path,
			accounts = api.GET.accounts(),
			transactions = api.GET.transactions(),
		})
		res.code = 200
		res.headers["Content-Type"] = mime.getType(file)
	end)

	.route({
		path = "/api/:name:",
		method = "POST"
	}, function (req, res)
		local api_request = api.POST[req.params.name]
		p(req.body)
		local query = parse_query(req.body)
		p(query)
		if api_request then
			api_request(query)
			res.code = 302
			res.headers.Location = "/"
		end
	end)

	.route({
		path = "/api/:name:",
		method = "GET"
	}, function (req, res)
		local api_request = api.GET[req.params.name] -- or api.POST[req.params.name]
		p(req.query)
		if api_request then
			res.body = json.stringify(api_request(req.query))
			res.code = 200
			res.headers["Content-Type"] = mime.getType("json")
		end
	end)

	.websocket({
		path = "/socket", -- Prefix for matching
		protocol = "echo", -- Restrict to a websocket sub-protocol
	}, function (req, read, write)
		-- Log the request headers
		p(req)
		-- Log and echo all messages
		for message in read do
			p(message)
			write(message)
		end
		-- End the stream
		write()
	end)

	-- Start the server
	.start()


