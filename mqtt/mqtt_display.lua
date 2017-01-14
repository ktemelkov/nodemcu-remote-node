

local function isvalid(client, hardware, config)
	local error = nil
	
	if config and config.id and config.sda and config.scl and config.sla then
		config.id = tonumber(config.id)
		config.sda = tonumber(config.sda)
		config.scl = tonumber(config.scl)
		config.sla = tonumber(config.sla)
				
		if hardware.GPIO[config.sda] ~= nil and hardware.GPIO[config.scl] ~= nil then			
			if client.isregistered("display" .. config.id .. ".close") then			
				error = "Display already configured!"
			end
		else
			error = "Invalid argument!"		
		end
	else
		error = "Invalid format!"
	end
		
	if error then
		client.publish("display.error", error)
	end

	return not error	
end


local function update_display(disp, drawList)		
	disp:firstPage(); 
	
	if next(drawList) == nil then
	   disp:begin()
	end	
	
	repeat 
		for k,v in pairs(drawList) do
			if v.type == 0 then
				disp:setFont(u8g.font_6x10)
				disp:drawStr(v.x, v.y, v.str)
			elseif v.type == 1 then
				disp:drawBitmap(v.x, v.y, v.w, v.h, v.bitmap)
			end
		end				
	until not disp:nextPage()
end


return function(client, hardware, config)
	_, config = pcall(cjson.decode, config)
	
	if isvalid(client, hardware, config) then
		i2c.setup(0, hardware.GPIO[config.sda].pin, hardware.GPIO[config.scl].pin, i2c.SLOW)
		
		local disp = u8g.ssd1306_128x64_i2c(config.sla)
		local prefix = "display" .. config.id
		local drawList = {}
		
		
		client.register(prefix .. ".drawStr", function(cl, pl)
			local res, v = pcall(cjson.decode, pl)
			
			if res and v.id and v.x and v.y and v.str then
				v.type = 0
				drawList[v.id] = v
				
				if v.update and (v.update == "1" or v.update == "true") then
					update_display(disp, drawList)
				end
			end			
		end)
		
		
		client.register(prefix .. ".drawBitmap", function(cl, pl) 
			local res, v = pcall(cjson.decode, pl)
			
			if res and v.id and v.x and v.y and v.w and v.h and v.bitmap then
				local res = nil
				
				res, v.bitmap = pcall(encoder.fromHex, v.bitmap)

				if res then
					v.type = 1
					drawList[v.id] = v
					
					if v.update and (v.update == "1" or v.update == "true") then
						update_display(disp, drawList)
					end
				end
			end			
		end)

		
		client.register(prefix .. ".clear", function(cl, pl)
			drawList = {}
			
			if pl == "1" or pl == "true" then
				update_display(disp, drawList)
			end
		end)

		
		client.register(prefix .. ".update", function(cl, pl) 
			update_display(disp, drawList)
		end)

		
		client.register(prefix .. ".close", function(cl, pl)
			update_display(disp, {})

			cl.unregister(prefix .. ".drawStr")
			cl.unregister(prefix .. ".drawXBM")
			cl.unregister(prefix .. ".clear")
			cl.unregister(prefix .. ".update")
			cl.unregister(prefix .. ".close")
		end)		
	end
end