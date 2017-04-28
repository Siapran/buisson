local weblit = require("weblit")
local socket = require("socket")
local controller = require("controller")

-- p(controller)

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

	-- .use(function ( req, res, go )
	-- 	print("Headers:")
	-- 	p(req.headers)
	-- 	go()
	-- end)

	.route({
		path = "/static/:path:"
	}, weblit.static("./static/"))

	.route({
		path = "/api/:name:",
		method = "POST"
	}, controller.api_post)

	.route({
		path = "/api/:name:",
		method = "GET"
	}, controller.api_get)

	.route({
		path = "/view/:path:",
		method = "GET"
	}, controller.view_get)

	.websocket({
		path = "/socket",
		protocol = "echo",
	}, socket.client_connection)

	.route({
		path = "/:path:",
		method = "GET"
	}, controller.page_get)

	.use(controller.not_found)

	-- Start the server
	.start()


