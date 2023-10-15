

local server = nil

function acceptConnection()
	local sock, err = server:accept()
	if err then
		console:error("Connection error " .. err)
		return
	end
	sock:add("received", function() receiveData(sock) end)
	sock:add("error", function() sock:close() end)
end

function receiveData(sock)
	local data = ""
	while true do
		local p, err = sock:receive(1024)
		if p then
			data = data .. p
		else
			if err ~= socket.ERRORS.AGAIN then
				console:error("Socket error " .. err)
				sock:close()
			else
				local req = parseHttp(data)
				if not req then
					return
				end
				local data = "Unknown"
				if req.method == "GET" and req.path == "/update" then
					data = getNetworkData()
				elseif req.method == "GET" and req.path == "/ping" then
					data = "Pong"
				end
				sock:send(string.format(
					"HTTP/1.1 200 OK\r\n" ..
					"Access-Control-Allow-Origin: *\r\n" ..
					"Content-Length: %s\r\n" ..
					"Content-Type: text/plain; charset=utf-8\r\n" ..
					"\r\n%s",
					data:len(),
					data
				))
			end
			return
		end
	end
end

function parseHttp(data)
	local head, body = string.match(data, "(..-)\r\n\r\n(.*)")
	if not (head and body) then
		return nil
	end
	local headers = split(head, "\r\n")
	local rawMethod, rawPath, rawVersion = string.match(headers[1], "(..-) (..-) (.+)")
	return {
		method = rawMethod,
		path = rawPath,
		version = rawVersion
	}
end

function setupServer()
	server, err = socket.bind(nil, 31123)
	if err then
		console:error("Bind error " .. err)
	else
		ok, err = server:listen()
		if err then
			server:close()
			console:error("Listen error " .. err)
		else
			server:add("received", acceptConnection)
		end
	end
end
