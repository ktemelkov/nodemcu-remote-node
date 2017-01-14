local s = {}

s.pend = 0
s.conf = false
s.srv = false

s.recv = function(con, pl, context)
	dofile("http_connection.lc")(con, s.conf, pl, context)
end


s.disc = function(con)
	s.pend = s.pend - 1
end


s.create = function()
	s.pend = 0
	s.srv = net.createServer(net.TCP, 1)
	s.srv:listen(tonumber(s.conf.http_port), s.accept)
end


s.close = function()
	s.srv:close()
	s.srv = false
end


s.accept = function(con)

	if s.pend > 1 then
		con:close()	
	else	
		s.pend = s.pend + 1
		
		local context = {}
		context.state = 0
		context.content_len = 0
		context.content_pos = 0
		
		con:on("disconnection", function(con)
			context = nil
			s.disc(con)
		end)
		
		con:on("receive", function(con, pl)
			s.recv(con, pl, context) 
		end)
	end
end	


return function(cfg)
	s.conf = cfg
	s.create()
	return s
end
