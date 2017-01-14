
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
		client.publish("rc.error", error)
	end

	return not error	
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		local gpiohw = hardware.GPIO[config.pin]
		local prefix = "rc" .. config.pin

		gpiohw.mode = hardware.PIN_MODE_PRERIPHERAL
				
		client.register(prefix .. ".send", function(cl,pl)
			local res, params = pcall(cjson.decode, pl)
			
			if res and params.code and params.bits and params.pulselen and params.protocol and params.rept then
				params.code = tonumber(params.code)
				params.bits = tonumber(params.bits)
				params.pulselen = tonumber(params.pulselen)
				params.protocol = tonumber(params.protocol)
				params.rept = tonumber(params.rept)
				
				rc.send(gpiohw.pin, code, bits, pulselen, protocol, rept)
			else
				client.publish(prefix .. ".error", "Invalid arguments!")
			end
		end)

		client.register(prefix .. ".close", function(cl, pl)			
			gpiohw.mode = -1
			
			cl.unregister(prefix .. ".send")
			cl.unregister(prefix .. ".close")
		end)	
	end
end
