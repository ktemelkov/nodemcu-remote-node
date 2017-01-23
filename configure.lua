wifi.setmode(wifi.SOFTAP)

wifi.ap.config({ ssid = "DEV_" .. string.gsub(string.sub(wifi.ap.getmac(), 10, 17), "[-:]", "")})
wifi.ap.setip({ ip = "192.168.1.1", netmask="255.255.255.0", gateway="192.168.1.1"})
wifi.ap.dhcp.config({start = "192.168.1.100"})
wifi.ap.dhcp.start()

if httpSrv then
    httpSrv:close()
    httpSrv = nil
end

file.remove("netconfig.lc")

httpSrv = dofile("http_server.lc")(dofile("default.lc"))
