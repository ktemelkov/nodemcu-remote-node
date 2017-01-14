-- dofile("compile.lua")

local rxPin = 9
local txPin = 10
	
tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() 
    
    uart.alt(1)    
    gpio.mode(rxPin, gpio.INPUT, gpio.PULLUP)       
    altBoot = (gpio.read(rxPin) == 0)

    if altBoot then
        gpio.mode(txPin, gpio.OUTPUT)
        gpio.write(txPin, 0)
        
        tmr.delay(500000)
        uart.alt(0)
        print("MODE: Configure\r\n")
        
        dofile("configure.lc")
    else
        uart.alt(0)
        print("MODE: Operate\r\n")

		-- initialize adc to read the external voltage (adc pin) 
		if not adc.force_init_mode(adc.INIT_ADC) then
			dofile("operate.lc")
		else
			print("ADC reconfigured to read external voltage! Restarting ...")
			node.restart()
		end
    end
end)
