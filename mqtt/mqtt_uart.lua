
local function isvalid(client, hardware, config)
	local error = nil

	if hardware.UART == nil then
		hardware.UART = { configured = false }
	end

	if config and config.baud and config.echo then
		config.baud = tonumber(config.baud)
		config.echo = tonumber(config.echo)
		
		if hardware.UART.configured then
			error = "UART already configured!"		
		end
		
	else
		error = "Invalid format!"
	end
	
	if error then
		client.publish("gpio.error", error)
	end
	
	return not error
end


return function(client, hardware, config)
	config = cjson.decode(config)
	
	if isvalid(client, hardware, config) then
		uart.setup(0, config.baud, 8, uart.PARITY_NONE, uart.STOPBITS_1, config.echo)
		hardware.UART.configured = true
	
		local uart_read = function(data)
			client.publish("uart0.message", data)
		end
		
		if config.msg_len then
			uart.on("data", tonumber(config.msg_len), uart_read, 0)		
		elseif config.end_char then
			uart.on("data", config.end_char, uart_read, 0)
		end

		client.register("uart0.write", function(cl, pl)
			uart.write(0, pl)
		end)
		
		client.register("uart0.close", function(cl, pl)
			uart.on("data")
			hardware.UART.configured = false

			cl.unregister("uart0.write")
			cl.unregister("uart0.close")
		end)			
	end
end