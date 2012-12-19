-module(wordabula_tcp_server).
-compile(export_all).

start_server(Port)->
	{ok,ListenSocket}=gen_tcp:listen(Port,[binary,{packet,0},{reuseaddr,true},{active,true}]),
        player_acceptor:start(ListenSocket).
	
	

