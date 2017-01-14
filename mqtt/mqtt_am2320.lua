
local function isvalid(client, hardware, config)
	local error = nil

	if config and config.sda and config.scl then
		config.sda = tonumber(config.sda)
		config.scl = tonumber(config.scl)
				
		if hardware.GPIO[config.sda] ~= nil and hardware.GPIO[config.scl] ~= nil then			
			if client.isregistered("am2320_0.close") then			
				error = "Sensor already configured!"
			end
		else
			error = "Invalid argument!"		
		end
	else
		error = "Invalid format!"
	end
		
	if error then
		client.publish("am2320.error", error)
	end

	return not error	
end


local function read_sample(cl) 
	local rh, t = am2320.read()
	cl.publish("am2320_0.sample", string.format("{\"humidity\":%d,\"temperature\":%d}", rh, t))
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		am2320.init(hardware.GPIO[config.sda].pin, hardware.GPIO[config.scl].pin)	

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
			
			hardware.IOTIMER[ticks].list["am2320_0"] = function()
				read_sample(client)
			end
		end
		
		
		client.register("am2320_0.read", read_sample)


		client.register("am2320_0.close", function(cl, pl)
			if ticks then
				hardware.IOTIMER[ticks].list["am2320_0"] = nil			
			end
			
			cl.unregister("am2320_0.read")
			cl.unregister("am2320_0.close")
		end)	
	end
end
