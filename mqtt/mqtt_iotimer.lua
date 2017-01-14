
local hw = nil

local function iotimer() 
	
	for k1,v1 in pairs(hw.IOTIMER) do
		local ticks = k1
		local list = v1.list

		v1.cnt = (v1.cnt + 1) % ticks

		if v1.cnt == 0 then
			for k2, v2 in pairs(list) do
				v2()
			end
		end
	end
end

return function(cl, hardw)
	hw = hardw
	return iotimer
end