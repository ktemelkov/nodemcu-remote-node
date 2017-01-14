
return function(conn, cfg, pl, context)
	
	local fcont = false
	
	if context.state == 0 then -- get headers
		context.state = -1
				
		local cred = pl:match("Authorization:%s+Basic%s+([A-Za-z0-9+/=]+)")
		
		if cred then
			cred = encoder.fromBase64(cred)
		end
		
		_, _, context.met, context.req = pl:find("^([A-Z]+)%s+(.-)%s+HTTP/[1-9]+.[0-9]+")
		
		if context.met and context.req then	
			if wifi.getmode() == wifi.SOFTAP or cred == (cfg.http_user .. ":" .. cfg.http_pass) then				
				context.path = context.req
				context.args = nil
								
				if context.req:find("?", 1, true) then
					context.path, context.args = context.req:match("(.-)?(.*)")
				end
				
				if context.met == "PUT" or context.met == "POST" then
					local clen = pl:match("Content%-Length:%s*(%d+)")

					if clen then
						context.content_len = tonumber(clen)
						context.content = {}
						
						local cont = pl:match("\r\n\r\n(.*)")
						
						if cont then
							table.insert(context.content, cont)
							context.content_pos = cont:len()
						end

						context.state = 1
					else
						dofile("http_error.lc")(conn, cfg, 400, "Bad Request")
					end
				else
					context.state = 1
					context.content = nil
					fcont = true
				end
			else
				dofile("http_error.lc")(conn, cfg, 401, "Not Authorized", string.format("WWW-Authenticate: Basic realm=\"%s\"\r\n", cfg.net_hostname))
			end				
		else
			dofile("http_error.lc")(conn, cfg, 400, "Bad Request")
		end
	elseif context.state == 1 then
		context.content_pos = context.content_pos + pl:len()
		table.insert(context.content, pl)
		
		if context.content_pos >= context.content_len then
			local t = context.content
			
			context.content = table.concat(context.content, "")
			
			for i,v in ipairs(t) do 
				t[i] = nil 
			end
			
			fcont = true			
			context.state = -1
		end
	end

	
	if fcont then
		if context.path == "/" then					
			dofile("http_configure.lc")(conn, cfg, context.met, context.path, context.args, context.content)
		elseif context.path == "/restart" then
			dofile("http_restart.lc")(conn, cfg, context.met, context.path, context.args, context.content)
		elseif context.path == "/ota/list" then
			dofile("http_ota_list.lc")(conn, cfg, context.met, context.path, context.args, context.content)
		elseif context.path:find("^/ota/exec") then
			dofile("http_ota_exec.lc")(conn, cfg, context.met, context.path, context.args, context.content)
		elseif context.path:find("^/ota/file") then
			dofile("http_ota_file.lc")(conn, cfg, context.met, context.path, context.args, context.content)
		else
			dofile("http_error.lc")(conn, cfg, 404, "Not Found")
		end
		
		if context.content then 
			context.content = nil
		end
	end
end
