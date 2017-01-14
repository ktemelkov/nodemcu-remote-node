
return function(conn, config, code, status, extraHeaders, mimeType, sentCallback)

	if extraHeaders == nil then
		extraHeaders = ""
	end

	local headers = table.concat({"Server: ", config.net_hostname, "\r\n",
			"Content-Type: ", mimeType, "\r\n",
			extraHeaders, 
			"Connection: close\r\n\r\n"}, "")

	conn:send(string.format("HTTP/1.0 %d %s\r\n%s", code, status, headers), function(c)
		if sentCallback then
			sentCallback(c)
		else
			c:close()
		end
	end)

end
