-module(player_acceptor).
-behaviour(gen_server).
-compile(export_all).
-export([init/1,handle_cast/2]).
-record(state,{listenSocket}).
start(ListenSocket)->
	gen_server:start_link({local, ?MODULE},?MODULE, ListenSocket, []).
 
init(ListenSocket) ->

	gen_server:cast(?MODULE,{wait_for_accept}),
	{ok, #state{listenSocket=ListenSocket}}.
 
%% We never need you, handle_call!
handle_call(_E, _From, State) ->
	{noreply, State}.
	
handle_cast({wait_for_accept},State)->
	spawn_link(
			fun()-> 
				{ok, PlayerSocket} = gen_tcp:accept(State#state.listenSocket),
				io:format("socket accepted! ~n"),
				gen_tcp:controlling_process(PlayerSocket,whereis(?MODULE)),
				gen_server:cast(?MODULE,{wait_for_accept}), 
				gen_server:cast(?MODULE,{connection_accepted,PlayerSocket}) 
				end
		  ),
	{noreply,State};
	
handle_cast({connection_accepted,PlayerSocket},State)->
	{ok,PlayerPid}= player:start(PlayerSocket),
	io:format("Pid of player:~p",[PlayerPid]),
	gen_tcp:controlling_process(PlayerSocket,PlayerPid),
	{noreply, State}.
	
