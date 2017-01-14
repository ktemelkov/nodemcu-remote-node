
-- Compile server code and remove original .lua files.
-- This only happens the first time afer the .lua files are uploaded.

local compileAndRemoveIfNeeded = function(f)
	if file.exists(f) then
		print('Compiling:', f)
		node.compile(f)
		file.remove(f)
	end
end

local serverFiles = {
	'http_server.lua',
	'http_configure.lua', 
	'http_error.lua', 
	'http_headers.lua', 
	'http_restart.lua', 
	'http_util.lua',
	'http_connection.lua',
	'http_ota_list.lua',
	'http_ota_exec.lua',
	'http_ota_file.lua',

	'mqtt_client.lua', 
	'mqtt_init.lua', 
	'mqtt_register.lua', 
	'mqtt_iotimer.lua', 
	'mqtt_node_update.lua',
	'mqtt_gpio.lua', 
	'mqtt_pwm.lua', 
	'mqtt_adc.lua', 
	'mqtt_rotary.lua', 
	'mqtt_uart.lua', 
	'mqtt_bmp085.lua', 
	'mqtt_am2320.lua', 
	'mqtt_dht.lua', 
	'mqtt_rc.lua', 
	'mqtt_display.lua',

	'configure.lua',
	'operate.lua',
	'default.lua',
	'netconfig.lua',
	'hardware_01.lua',
	'hardware_12.lua', 
}

for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

print('Compile done.')
