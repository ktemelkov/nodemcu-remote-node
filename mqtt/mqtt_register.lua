local periph = {"gpio", "pwm", "adc", "rotary", "uart", "bmp085", "am2320", "rc", "dht", "display"}


local function nodeInfo(c, pl) 
	local info = {}
	info.majorVer, info.minorVer, info.devVer, info.chipid, info.flashid, info.flashsize, info.flashmode, info.flashspeed = node.info()
		
	local ok, json = pcall(cjson.encode, info)

	if ok then
		c.publish("node.info", json)
	else
		c.publish("node.error", "node.info failed!")
	end
end
	
	
return function(cl, hw)
	
	for k,v in ipairs(periph) do
		cl.register(v .. ".setup", function(c, pl)
			dofile("mqtt_" .. v .. ".lc")(c, hw, pl)
		end)
	end

	
	cl.register("node.input", function(c, pl) 
		node.input(pl)
	end)

	
	cl.register("node.output", function(c, pl) 
		if pl == "true" or tonumber(pl) == 1 then
			node.output(function(str) c.publish("node.print", str) end, 1)
		else
			node.output(nil, 1)	
		end
	end)

	cl.register("node.update", function(c, url) 
		dofile("mqtt_node_update.lc")(c, url)
	end)
	
	cl.register("node.getinfo", nodeInfo)


	cl.register("/discover", nodeInfo)

	
	cl.register("node.restart", function(c, pl) 
		tmr.alarm(0, 500, tmr.ALARM_SINGLE, node.restart)
	end)

end