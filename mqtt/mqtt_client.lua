
local m = {}
m.rout = {}
m.conf = false
m.conn = false


function m.connect(ip)
	m.conn:connect(ip, tonumber(m.conf.mqtt_port), 0, 0,
		function(c)		
			c:subscribe("/discover", 0)
			c:subscribe(m.conf.mqtt_topic .. "#", 0, function(c) print("MQTT subscribe success.") end)
			c:publish(m.conf.mqtt_topic .. "node.status", "online", 0, 0)
		end, 
		function(c, reason)
			print("MQTT connect failed! Reason: " .. reason) 
			tmr.alarm(3, 3000, tmr.ALARM_SINGLE, m.resolve)
		end)			
end


function m.resolve()

	if m.conf.mqtt_broker:find("^%d+%.%d+%.%d+%.%d+$") then
		m.connect(m.conf.mqtt_broker)
	else
		llmnr.lookup(m.conf.mqtt_broker, function(name, ip)		
			if not ip then 
				print("Cannot resolve mqtt broker: " .. name)
				tmr.alarm(3, 3000, tmr.ALARM_SINGLE, m.resolve)
			else
				m.connect(ip)	
			end 
		end)
	end
end


function m.close()
	if m.conn then
		m.conn:close()
		m.conn = nil
	end
end


function m.publish(path, data, qos, ret)
	if qos == nil then qos = 0 end
	if ret == nil then ret = 0 end

	if m.conn then
		m.conn:publish(m.conf.mqtt_topic .. path, data, qos, ret)
	end
end


function m.register(path, fn)	
	m.rout[path] = fn
end


function m.unregister(path)
	if m.rout[path] ~= nil then
		m.rout[path] = nil
	end
end	


function m.isregistered(path)
	return m.rout[path] ~= nil
end	


function m.msgcb(c, t, pl)
	if t and pl then
		if t ~= "/discover" then
			t = t:sub(m.conf.mqtt_topic:len() + 1, -1)
		end
		
		if m.rout[t] then
			m.rout[t](m, pl)
		end
	end
end


function m.oflcb()		
	print("MQTT client disconnected!") 
	tmr.alarm(3, 3000, tmr.ALARM_SINGLE, m.resolve)
end

	
return function(cfg, hw, cb)
	dofile("mqtt_init.lc")(m, cfg, m.msgcb, m.oflcb)
	
	m.resolve()

	if cb then 
		cb(m, hw)
	end
	
	return m
end
