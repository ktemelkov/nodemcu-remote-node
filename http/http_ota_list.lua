
return function(conn, cfg, method, path, args, content)
	if method == "GET" then		
		dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/plain", function(conn)

			local l = file.list()
			local t = {}
			
			for i,j in pairs(l) do
				table.insert(t, string.format("%s : %d", i, j))
			end
			
			if l then
				conn:send(table.concat(t, "\r\n"), function(c) c:close() end)
			end
			
		end)
	else
		dofile("http_error.lc")(conn, cfg, 405, "Invalid Method")
	end	
end
