
return function(m, cfg, msgcb, oflcb)

	if cfg.mqtt_topic and cfg.mqtt_topic:sub(-1, -1) ~= "/" then
		cfg.mqtt_topic = cfg.mqtt_topic .. "/"
	end

	cfg.mqtt_broker = cfg.mqtt_broker:gsub("%s+", "")

	m.conf = cfg
	
	m.conn = mqtt.Client(m.conf.net_hostname, 10, m.conf.mqtt_user, m.conf.mqtt_passwd)
	
	m.conn:lwt(m.conf.mqtt_topic .. "node.status", "offline", 0, 0)	
	m.conn:on("message", msgcb)
	m.conn:on("offline", oflcb)
end