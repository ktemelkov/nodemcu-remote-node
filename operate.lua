local cfg = file.exists("netconfig.lc") and dofile("netconfig.lc") or dofile("default.lc")

if not cfg.net_ssid or cfg.net_ssid == "" then 
    print("Not configured!")
    dofile("configure.lc")
    return 
end


wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T) 
    print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: ".. T.netmask.."\n\tGateway IP: "..T.gateway)

	local hw = dofile("hardware.lc")

	mdns.register(cfg.net_hostname)
	llmnr.register(cfg.net_hostname)

    httpSrv = dofile("http_server.lc")(cfg)		
	mqttClient = dofile("mqtt_client.lc")(cfg, hw, dofile("mqtt_register.lc"))

	tmr.alarm(1, hw.IO_TIMER_INTERVAL_MS, tmr.ALARM_AUTO, dofile("mqtt_iotimer.lc")(mqttClient, hw))
end)


wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T) 
    print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: ".. T.BSSID.."\n\treason: "..T.reason)

	tmr.unregister(1)
	
	if mqttClient then
		mqttClient.close()
		mqttClient = nil
	end
	
    if httpSrv then
        httpSrv.close()
        httpSrv = nil
    end

    llmnr.close()
	mdns.close()
end)

wifi.setmode(wifi.STATION)
wifi.sta.config(cfg.net_ssid, cfg.net_pass, 1)
