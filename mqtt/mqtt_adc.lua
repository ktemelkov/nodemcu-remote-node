
local function isvalid(client, hardware, config)
	local error = nil

	if config and config.channel then
		config.channel = tonumber(config.channel)
		
		if hardware.ADC[config.channel] then
			if hardware.ADC[config.channel].configured then
				error = "ADC channel already used!"
			end
		else
			error = "Invalid ADC channel!"
		end
	else
		error = "Invalid format!"
	end

	if error then
		client.publish("adc.error", error)
	end

	return not error
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)

	if isvalid(client, hardware, config) then
		local adchw = hardware.ADC[config.channel]
		local prefix = "adc" .. config.channel
		local ticks = nil
		
		adchw.configured = true
		
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
				client.publish(prefix .. ".sample", adc.read(config.channel))
			end
		end
		
		client.register(prefix .. ".read", function(cl, pl) 
			cl.publish(prefix .. ".sample", adc.read(config.channel))
		end)
		
		client.register(prefix .. ".close", function(cl, pl) 
			
			if ticks then
				hardware.IOTIMER[ticks].list[prefix] = nil
			end
			
			adchw.configured = false

			cl.unregister(prefix .. ".read")
			cl.unregister(prefix .. ".close")
		end)
	end
end