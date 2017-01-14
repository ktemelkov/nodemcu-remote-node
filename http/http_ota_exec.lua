
return function(conn, cfg, method, path, args, content)
	if method == "GET" then
		if args and file.exists(args) then
			
			local out = ""
			node.output(function(str) out = out .. str end, 1)

			dofile(args)

			node.output(nil, 1)	
			
			dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/plain", function(conn)
				conn:send(out, function(c) c:close() end)			
			end)
		else
			dofile("http_error.lc")(conn, cfg, 400, "Bad Request")
		end
	else
		dofile("http_error.lc")(conn, cfg, 405, "Invalid Method")
	end	
end
