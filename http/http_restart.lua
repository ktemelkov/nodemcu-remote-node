return function(conn, cfg, method, path, args, content)

	dofile("http_headers.lc")(conn, cfg, 200, "OK", "", "text/html", function(conn)
		conn:send("<h1>Device restarted</h1>", function(conn)
			if wifi.getmode() == wifi.SOFTAP and cfg.net_ssid and cfg.net_ssid ~= "" then
				conn:send("<p>Please connect to the confiugred WiFi network and access it <a href='http://" .. cfg.net_hostname .. "'>here</a>.</p>", function(conn) 
					conn:close() 
				end)
			else
				conn:send("<script>setTimeout(function(){window.location='/'},3000);</script><p>Reconnecting in 3 seconds ...</p>", function(conn)
					conn:send("<script>setTimeout(function(){window.location='/'},3000);</script>", function(conn)
						conn:close()
					end) 
				end)
			end
		end)
	end)
	
    tmr.alarm(0, 500, tmr.ALARM_SINGLE, function()
        node.restart() 
    end)
end


