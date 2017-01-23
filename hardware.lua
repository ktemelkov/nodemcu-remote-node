
return {

	-- available GPIOs
	GPIO = 
	{ 
		[0] = { pin = 3, mode = -1, history = 0xFF, state = 0}, 
		[1] = { pin = 10, mode = -1, history = 0xFF, state = 0}, 
		[2] = { pin = 4, mode = -1, history = 0xFF, state = 0}, 
		[3] = { pin = 9, mode = -1, history = 0xFF, state = 0}, 
		[4] = { pin = 2, mode = -1, history = 0xFF, state = 0}, 
		[5] = { pin = 1, mode = -1, history = 0xFF, state = 0}, 
		[9] = { pin = 11, mode = -1, history = 0xFF, state = 0}, 
		[10] = { pin = 12, mode = -1, history = 0xFF, state = 0}, 
		[12] = { pin = 6, mode = -1, history = 0xFF, state = 0}, 
		[13] = { pin = 7, mode = -1, history = 0xFF, state = 0}, 
		[14] = { pin = 5, mode = -1, history = 0xFF, state = 0}, 
		[15] = { pin = 8, mode = -1, history = 0xFF, state = 0}, 
		[16] = { pin = 0, mode = -1, history = 0xFF, state = 0}, 
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
