-- local _require = loadstring('return require')() -- Get the real require back :<
local weblit = require("weblit")
local template = require("resty/template")
local mime = require("mime")
local json = require("json")
local api = require("api")

weblit.app

	.bind({
		host = "127.0.0.1",
		port = 8080
	})

	-- Configure weblit server
	.use(weblit.logger)
	.use(weblit.autoHeaders)
	-- .use(weblit.etagCache)
	.use(weblit.cors)

	.route({
		path = "/static/:path:"
	}, weblit.static("/home/siapran/Programming/Lua/buisson/static/"))

	-- A custom route that sends back method and part of url.
	.route({
		path = "/",
		method = "GET"
	}, function (req, res)
		local file = "html/index.html"
		res.body = template.compile(file)({
			method = req.method,
			path = req.path
		})
		res.code = 200
		res.headers["Content-Type"] = mime.getType(file)
	end)

	.route({
		path = "/api/:name:",
		method = "POST"
	}, function (req, res)
		local file = "html/index.html"
		res.body = "OK"
		res.code = 200
		res.headers["Content-Type"] = mime.getType("text")
	end)

	.route({
		path = "/api/:name:",
		method = "GET"
	}, function (req, res)
		local api_request = api.GET[req.params.name]
		if api_request then
			res.body = json.stringify(api_request())
			res.code = 200
			res.headers["Content-Type"] = mime.getType("json")
		else
			res.body = "Not found"
			res.code = 404
			res.headers["Content-Type"] = mime.getType("text")
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


