

local function isvalid(client, hardware, config)
	local error = nil
	
	if config and config.pin and config.mode and config.pull then
		config.pin = tonumber(config.pin)
		
		if hardware.PIN_MODE[config.mode] then 
			config.mode = hardware.PIN_MODE[config.mode] 
		else 
			config.mode = tonumber(config.mode)
		end

		if hardware.PIN_RESISTOR[config.pull] then 
			config.pull = hardware.PIN_RESISTOR[config.pull] 
		else 
			config.pull = tonumber(config.pull)
		end
				
		if hardware.GPIO[config.pin] and hardware.PIN_MODE[config.mode] and hardware.PIN_RESISTOR[config.pull] then
			
			if hardware.GPIO[config.pin].mode ~= -1 then
				error = "Pin already assigned!"
			end
		else
			error = "Invalid argument!"
		end
	else
		error = "Invalid format!"
	end

	if error then
		client.publish("gpio.error", error)
	end

	return not error
end


local function poll_gpio(client, gpiohw, prefix)
	gpiohw.history = bit.lshift(gpiohw.history, 1)		
	gpiohw.history = gpiohw.history + gpio.read(gpiohw.pin)

	if bit.band(gpiohw.history, 0xC7) == 0xC0 then -- button pressed			
		gpiohw.history = 0x00
		gpiohw.state = 1
		
		if client then
			client.publish(prefix .. ".state", gpiohw.state)
		end
	end

	if bit.band(gpiohw.history, 0xC7) == 7 then -- button released			
		gpiohw.history = 0xFF
		gpiohw.state = 0
		
		if client then
			client.publish(prefix .. ".state", gpiohw.state)
		end
	end
end


return function(client, hardware, config)	
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		local prefix = "gpio" .. config.pin
		local gpiohw = hardware.GPIO[config.pin]
		gpiohw.mode = config.mode
		
		gpio.mode(gpiohw.pin, config.mode, config.pull)
	
		if config.mode == gpio.OUTPUT or config.mode == gpio.OPENDRAIN then				
			client.register(prefix .. ".write", function(cl, pl)			
				local gpio_new_state = tonumber(pl)
				
				if gpio_new_state < 0 then 
					gpiohw.state = (gpiohw.state + 1) % 2
				else
					gpiohw.state = gpio_new_state
				end
				
				gpio.write(gpiohw.pin, gpiohw.state)
				
				cl.publish(prefix .. ".state", gpiohw.state)
			end)
		else
			local ticks = hardware.INPUT_DEBOUNCE_TICKS

			if not hardware.IOTIMER[ticks] then
				hardware.IOTIMER[ticks] = { cnt = 0, list = {}}
			end
			
			hardware.IOTIMER[ticks].list[prefix] = function()
				poll_gpio(client, gpiohw, prefix)
			end
		end
		
		client.register(prefix .. ".read", function(cl, pl)
			cl.publish(prefix .. ".state", gpiohw.state)
		end)
		
		client.register(prefix .. ".close", function(cl, pl) 		
			
			hardware.IOTIMER[hardware.INPUT_DEBOUNCE_TICKS].list[prefix] = nil

			gpiohw.mode = -1

			cl.unregister(prefix .. ".write")
			cl.unregister(prefix .. ".read")
			cl.unregister(prefix .. ".close")
		end)
	end
end
