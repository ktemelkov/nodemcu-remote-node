
return function(conn, config, code, message, headers)

	if headers == nil then
		headers = ""
	end

	dofile("http_headers.lc")(conn, config, code, message, headers, "text/html", function(cn)	
		cn:send(table.concat({"<html><head><title>", code, " - ", message, "</title></head><body><h1>",
					code, " - ", message, "</h1></body></html>\r\n"}, ""), function(c)
			c:close()
		end) 
	end)
end
