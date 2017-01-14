
return function(conn, cfg, method, path, args, content)

	if args and (method ~= "GET" or file.exists(args)) and ((method ~= "GET" and method ~= "PUT") or args:find("%.lua$")) then
		if method == "GET" then			

			file.open(args, "r")
			
			local size = file.seek("end", 0)
			file.seek("set", 0)

			local buff = {}			
			local chunk = file.read(512)
					
			while chunk do
				table.insert(buff, chunk)
				chunk = file.read(512)
			end

			file.close()
			
			dofile("http_headers.lc")(conn, cfg, 200, "OK", string.format("Content-Length: %d\r\n", size), "text/plain", function(c)
				c:send(table.concat(buff, ""), function(c) c:close() end)
			end)
			
		elseif method == "PUT" then
			file.open(args, "w+")
			file.write(content)
			file.close()
			
			dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/plain", function(con)
				con:send(string.format("File %s saved.", args), function(c) c:close() end)
			end)
		elseif method == "DELETE" then
			file.remove(args)

			dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/plain", function(con)
				con:send(string.format("File %s deleted.", args), function(c) c:close() end)
			end)
		else
			dofile("http_error.lc")(conn, cfg, 405, "Invalid Method")	
		end	
	else
		dofile("http_error.lc")(conn, cfg, 400, "Bad Request")
	end
end
