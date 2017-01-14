return {
    net_ssid = "",  -- "M-Tel_B09F"
    net_pass = "", -- "4857544318B09F13"
    
    net_hostname = "DEV_" .. string.gsub(string.sub(wifi.ap.getmac(), 10, 17), "[-:]", ""),

	http_port = "80",
    http_user = "admin",
    http_pass = "",
    
	mqtt_broker = "",
	mqtt_user = "",
	mqtt_passwd = "",
	mqtt_port = "1883",
	mqtt_topic = "",
}
