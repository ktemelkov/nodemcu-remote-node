
local function isvalid(client, hardware, config)
	local error = nil

	if hardware.ROTARY == nil then
		hardware.ROTARY = { 
			[0] = { configured = false },
			[1] = { configured = false },
			[2] = { configured = false },
		}			
	end
	
	if config and config.channel and config.pina and config.pinb then
		config.channel = tonumber(config.channel)
		config.pina = tonumber(config.pina)
		config.pinb = tonumber(config.pinb)
	
		if config.pinpress then
			config.pinpress = tonumber(config.pinpress)
		end
				
		if hardware.ROTARY[config.channel] ~= nil and hardware.GPIO[config.pina] ~= nil 
				and hardware.GPIO[config.pinb] ~= nil and (config.pinpress == nil or hardware.GPIO[config.pinpress] ~= nil) then
			
			if hardware.ROTARY[config.channel].configured == false then
			
				if hardware.GPIO[config.pina].mode ~= -1 or hardware.GPIO[config.pinb].mode ~= -1 
						or (config.pinpress ~= nil and hardware.GPIO[config.pinpress].mode ~= -1) then
						
					error = "Specified pin(s) already assigned!"				
				end				
			else
				error = "Channel already configured!"
			end
		else
			error = "Invalid argument!"		
		end
	else
		error = "Invalid format!"
	end
		
	if error then
		client.publish("rotary.error", error)
	end

	return not error	
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)

	if isvalid(client, hardware, config) then					
		local rothw = hardware.ROTARY[config.channel]
		local gpioahw = hardware.GPIO[config.pina]
		local gpiobhw = hardware.GPIO[config.pinb]
		local gpioprhw = hardware.GPIO[config.pinpress]
		local prefix = "rotary" .. config.channel
		
		rothw.configured = true
		gpioahw.mode = hardware.PIN_MODE_PRERIPHERAL
		gpiobhw.mode = hardware.PIN_MODE_PRERIPHERAL
		
		if config.pinpress then
			gpioprhw.mode = hardware.PIN_MODE_PRERIPHERAL					
			rotary.setup(config.channel, gpioahw.pin, gpiobhw.pin, gpioprhw.pin)
		else
			rotary.setup(config.channel, gpioahw.pin, gpiobhw.pin)
		end
		
		
		client.register(prefix .. ".close", function(cl, pl)
			rotary.close(config.channel)

			gpioahw.mode = -1
			gpiobhw.mode = -1
			rothw.configured = false
			
			if config.pinpress then
				gpioprhw.mode = -1
			end

			cl.unregister(prefix .. ".close")
		end)
		
		rotary.on(config.channel, rotary.ALL, function(eventType, pos, when)
			if eventType == rotary.PRESS then
				client.publish(prefix .. ".press", pos)
			elseif eventType == rotary.LONGPRESS then
				client.publish(prefix .. ".longpress", pos)
			elseif eventType == rotary.RELEASE then
				client.publish(prefix .. ".release", pos)
			elseif eventType == rotary.TURN then
				client.publish(prefix .. ".turn", pos)
			elseif eventType == rotary.CLICK then
				client.publish(prefix .. ".click", pos)
			elseif eventType == rotary.DBLCLICK then
				client.publish(prefix .. ".dblclick", pos)
			end
		end)					
	end
end
