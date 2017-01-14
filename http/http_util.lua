local u = {}

u.url_decode = function(str)        
	return str:gsub("+", " "):gsub("%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)    
end


u.xml_escape = function(s)
	return s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("'", "&apos;"):gsub('"', "&quot;")
end


u.parseFormData = function(body)
	local data = {}
	
	for kv in string.gmatch(body, "%s*&?([^=]+=[^&]+)") do
		local key, value = string.match(kv, "(.*)=(.*)")
		data[key] = u.url_decode(value)
	end
	
	return data
end

return u

