local weblit = require("weblit")

weblit.app

	.bind({
		host = "127.0.0.1",
		port = 8080
	})

	-- Configure weblit server
	.use(weblit.logger)
	.use(weblit.autoHeaders)
	.use(weblit.etagCache)
	.use(weblit.cors)

	.route({
		path = "/static/:path:"
	}, weblit.static("/home/siapran/Programming/Lua/buisson/static/"))

	-- A custom route that sends back method and part of url.
	.route({
		path = "/index.html"
	}, function (req, res)
		res.body = req.method .. " - " .. req.params.name .. "\n"
		res.code = 200
		res.headers["Content-Type"] = "text/plain"
	end)

	.route

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


