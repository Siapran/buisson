
local clients = {}

local function client_connection (req, read, write)
	-- Log the request headers
	p("New client", req.socket)
	
	-- Log and echo all messages
	for message in read do
		p(message)
		write(message)
	end
	-- End the stream
	write()
end

local package = {
	client_connection = client_connection
}
return package

