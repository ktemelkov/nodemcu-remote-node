
local function isvalid(client, hardware, config)
	local error = nil
	
	if hardware.used_pwms == nil then
		hardware.used_pwms = 0
	end
	
	if config and config.pin and config.clock and config.duty then
		config.pin = tonumber(config.pin)
		config.clock = tonumber(config.clock)
		config.duty = tonumber(config.duty)
		
		local gpiohw = hardware.GPIO[config.pin]
		
		if gpiohw and config.clock >= hardware.PWM_MIN_CLOCK and config.clock <= hardware.PWM_MAX_CLOCK 
			and config.duty >= hardware.PWM_MIN_DUTY and config.duty <= hardware.PWM_MAX_DUTY then
			
			if gpiohw.mode == -1 then
											
				if hardware.used_pwms >= hardware.PWM_MAX_PWM_PINS then 
					error = "Maximum number of PWM pins exceeded!"
				end
			else
				error = "Pin already assigned!"
			end
		else
			error = "Invalid argument!"
		end	
	else
		error = "Invalid format!"
	end

	if error then
		client.publish("pwm.error", error)
	end
	
	return not error
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		local gpiohw = hardware.GPIO[config.pin]
		local prefix = "pwm" .. config.pin
	
		pwm.setup(gpiohw.pin, config.clock, config.duty)
		gpiohw.mode = hardware.PIN_MODE_PRERIPHERAL
		hardware.used_pwms = hardware.used_pwms + 1
		
		if config.autostart and (config.autostart == "true" or tonumber(config.autostart) == 1) then
			pwm.start(gpiohw.pin)
		end
		
		client.register(prefix .. ".start", function(cl, pl) 
			pwm.start(gpiohw.pin)
		end)
		
		client.register(prefix .. ".stop", function(cl, pl) 
			pwm.stop(gpiohw.pin)
		end)
		
		client.register(prefix .. ".close", function(cl, pl) 
			pwm.close(gpiohw.pin)
			
			gpiohw.mode = -1
			hardware.used_pwms = hardware.used_pwms - 1 

			cl.unregister(prefix .. ".start")
			cl.unregister(prefix .. ".stop")
			cl.unregister(prefix .. ".close")
			cl.unregister(prefix .. ".setclock")
			cl.unregister(prefix .. ".setduty")
			cl.unregister(prefix .. ".getclock")
			cl.unregister(prefix .. ".getduty")
		end)

		client.register(prefix .. ".setclock", function(cl, pl)
			local pwm_clock = tonumber(pl)
			
			if pwm_clock >= hardware.PWM_MIN_CLOCK and pwm_clock <= hardware.PWM_MAX_CLOCK then
				pwm.setclock(gpiohw.pin, pwm_clock)
			else
				cl.publish(prefix .. ".error", "Invalid PWM clock!")					
			end
		end)
		
		client.register(prefix .. ".setduty", function(cl, pl)
			local pwm_duty = tonumber(pl)
			
			if pwm_duty >= hardware.PWM_MIN_DUTY and pwm_duty <= hardware.PWM_MAX_DUTY then
				pwm.setduty(gpiohw.pin, pwm_duty)
			else
				cl.publish(prefix .. ".error", "Invalid PWM duty cycle!")					
			end
		end)

		client.register(prefix .. ".getclock", function(cl, pl)						
			cl.publish(prefix .. ".clock", pwm.getclock(gpiohw.pin))					
		end)

		client.register(prefix .. ".getduty", function(cl, pl)						
			cl.publish(prefix .. ".duty", pwm.getduty(gpiohw.pin))					
		end)
	end
end