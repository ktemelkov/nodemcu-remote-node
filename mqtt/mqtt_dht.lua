
local function isvalid(client, hardware, config)
	local error = nil

	if config and config.pin then
		config.pin = tonumber(config.pin)		

		local gpiohw = hardware.GPIO[config.pin]

		if gpiohw then
			if gpiohw.mode ~= -1 then
				error = "Pin already assigned!"
			end			
		else
			error = "Invalid argument!"		
		end
	else
		error = "Invalid format!"
	end
		
	if error then
		client.publish("dht.error", error)
	end

	return not error	
end


local function read_sample(cl, pin, prefix) 
	local status, temp, humi, temp_dec, humi_dec = dht.read(pin)

	if status == dht.OK then
		cl.publish(prefix .. ".sample", string.format("{\"humidity\":%d.%03d,\"temperature\":%d.%03d}", math.floor(humi), humi_dec, math.floor(temp), temp_dec))
	elseif status == dht.ERROR_CHECKSUM then
		cl.publish(prefix .. ".error", "DHT Checksum error.")
	elseif status == dht.ERROR_TIMEOUT then
		cl.publish(prefix .. ".error", "DHT timed out.")
	end	
	
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		local gpiohw = hardware.GPIO[config.pin]
		local prefix = "dht" .. config.pin

		gpiohw.mode = hardware.PIN_MODE_PRERIPHERAL

		local ticks = nil
		
		if config.sample_time ~= nil and tonumber(config.sample_time) > 0 then
			config.sample_time = tonumber(config.sample_time)
			
			if config.sample_time < hardware.IO_TIMER_INTERVAL_MS then 
				config.sample_time = hardware.IO_TIMER_INTERVAL_MS
			end

			ticks = math.floor(config.sample_time/hardware.IO_TIMER_INTERVAL_MS)

			if not hardware.IOTIMER[ticks] then
				hardware.IOTIMER[ticks] = { cnt = 0, list = {}}
			end
			
			hardware.IOTIMER[ticks].list[prefix] = function()
				read_sample(client, gpiohw.pin, prefix)
			end
		end
		
		
		client.register(prefix .. ".read", function(cl,pl)
			read_sample(client, gpiohw.pin, prefix)
		end)

		
		client.register(prefix .. ".close", function(cl, pl)
			if ticks then
				hardware.IOTIMER[ticks].list[prefix] = nil			
			end
			
			gpiohw.mode = -1
			
			cl.unregister(prefix .. ".read")
			cl.unregister(prefix .. ".close")
		end)	
	end
end
