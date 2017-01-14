
return function(conn, cfg, method, path, args, content)
    local util = dofile("http_util.lc")

    if method == "GET" then    

		local function part5(conn)
			conn:send("<tr><td/><td>&nbsp;</td></tr>"
					.. "<tr><td/><td><input type='submit' value='Save'/> <input type='button' value='Restart' onClick='window.location=\"/restart\";return false;'/></td></tr></table>"
					.. "</form></body></html>", function(conn)
				conn:close()			
			end)
		end

		local function part4(conn)
			conn:send("<tr><td><b>MQTT SETTINGS</b></td><td></td></tr>"
					.. "<tr><td>Broker address:</td><td><input name='mqtt_broker' value='" .. util.xml_escape(cfg.mqtt_broker) .. "'/></td></tr>"
					.. "<tr><td>Broker port:</td><td><input name='mqtt_port' value='" .. util.xml_escape(cfg.mqtt_port) .. "'/></td></tr>"
					.. "<tr><td>Username:</td><td><input name='mqtt_user' value='" .. util.xml_escape(cfg.mqtt_user) .. "'/></td></tr>"
					.. "<tr><td>Password:</td><td><input name='mqtt_passwd' value='" .. util.xml_escape(cfg.mqtt_passwd) .. "'/></td></tr>"
					.. "<tr><td>Topic:</td><td><input name='mqtt_topic' value='" .. util.xml_escape(cfg.mqtt_topic) .. "'/></td></tr>", part5)
		end
		
		local function part3(conn)
			conn:send("<tr><td><b>HOST SETTINGS</b></td><td></td></tr>"
					.. "<tr><td>Host name:</td><td><input name='net_hostname' value='" .. util.xml_escape(cfg.net_hostname) .. "'/></td></tr>"
					.. "<tr><td>Username:</td><td><input name='http_user' value='" .. util.xml_escape(cfg.http_user) .. "'/></td></tr>"
					.. "<tr><td>Password:</td><td><input name='http_pass' type='password' value='" .. util.xml_escape(cfg.http_pass) .. "'/></td></tr>"
					.. "<tr><td/><td>&nbsp;</td></tr>", part4)
		end
		
		local function part2(conn)
			conn:send("</style></head><body><h1 style='background-color:#58D;color:#FFF'>&nbsp;Device Setup</h1>"
					.. "<form method='POST' action='/'><table>"
					.. "<tr><td><b>WIRELESS SETTINGS</b></td><td></td></tr>"
					.. "<tr><td>SSID:</td><td><input name='net_ssid' value='" .. util.xml_escape(cfg.net_ssid) .. "'/></td></tr>"
					.. "<tr><td>Password:</td><td><input name='net_pass' type='password' value='" .. util.xml_escape(cfg.net_pass) .. "'/></td></tr>"
					.. "<tr><td/><td>&nbsp;</td></tr>", part3)
		end
		
		local function part1(conn)
			conn:send("<html><head><style>"
					.. "body{font-size:1em;} table{font-size:1em;}"
					.. "@media only screen and (max-width:1024px){body{font-size:4em;} table{font-size:0.9em;} input, select{font-size:0.9em;}}", part2)
		end
		
		dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/html", part1)
		
	elseif method == "POST" then
		if content ~= nil and content ~= "" then
			content = util.parseFormData(content)
		
			for name,value in pairs(content) do            
				value = string.gsub(value, "\"", "\\\"")
				
				if string.match(name, "[_%a][_%w]*") and cfg[name] ~= nil then
					cfg[name] = value
				end    
			end        
						   
			local f = "netconfig.lua"
			
			if file.open(f, "w+") then
				file.writeline("return {")
				
				for name, value in pairs(cfg) do                
					file.writeline(name .. "=\"" .. value .. "\",")
				end
		
				file.writeline("}")
				file.close()
				
				node.compile(f)
				file.remove(f)
				f = ""
			end

			if f == "" then
				f = "<h1>Configuration saved</h1><p>Go <a href='/'>back</a>.</p>"
			else
				f = "<h1>Unable to save configuration</h1><p>Go <a href='/'>back</a>.</p>"
			end
			
			dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/html", function(conn)	  
				conn:send(f, function(conn)
					conn:close()
				end)
			end)
		else
			dofile("http_error.lc")(conn, cfg, 400, "Bad Request")		
		end
	else
        dofile("http_error.lc")(conn, cfg, 405, "Method Not Allowed")
    end
end
