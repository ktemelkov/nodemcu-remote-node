
return {

	-- available GPIOs
	GPIO = 
	{ 
		[0] = { pin = 3, mode = -1, history = 0xFF, state = 0},
		[2] = { pin = 4, mode = -1, history = 0xFF, state = 0}, 
	},

	INPUT_DEBOUNCE_TICKS = 1, -- debounce interval = INPUT_DEBOUNCE_TICKS x IO_TIMER_INTERVAL_MS
	IO_TIMER_INTERVAL_MS = 20,
	
	-- available modes for GPIOs
	PIN_MODE = 
	{
		[0] = gpio.INPUT,
		[1] = gpio.OUTPUT,
		[3] = gpio.OPENDRAIN,
		["input"] = gpio.INPUT, -- 0: input
		["output"] = gpio.OUTPUT, -- 1: output
		["opendrain"] = gpio.OPENDRAIN, -- 2: output open drain
	},
	
	PIN_MODE_PRERIPHERAL = 4,
	
	-- available pullup/pulldown resistors for GPIOs
	PIN_RESISTOR =
	{
		[0] = gpio.FLOAT,
		[1] = gpio.PULLUP,
		["float"] = gpio.FLOAT,
		["pullup"] = gpio.PULLUP,
	},	

	PWM_MIN_CLOCK = 1,
	PWM_MAX_CLOCK = 1000,
	PWM_MIN_DUTY = 0,
	PWM_MAX_DUTY = 1023,
	PWM_MAX_PWM_PINS = 6,
	
	ADC =
	{
		[0] = { configured = false },
	},
	
	IOTIMER = {},
}
