-module(player).
-behaviour(gen_server).
-compile(export_all).
-export([init/1,handle_cast/2,handle_info/2]).
-record(state,{playerSocket,pidofTable}).
start(PlayerSocket)->
	gen_server:start(?MODULE, [PlayerSocket], []).
 
init([PlayerSocket]) ->
	{ok, #state{playerSocket=PlayerSocket}}.
	
send_broadcast(Pid,Data)->
	gen_server:cast(Pid,{send_broadcast,{Pid,Data}}).
	
receive_broadcast(Pid,Message={receive_broadcast,{From,Data}})->
	gen_server:cast(Pid,Message).

%% We never need you, handle_call!
handle_call(_E, _From, State) ->
{noreply, State}.

handle_info({tcp, Socket, Bin},State) when Socket=:=State#state.playerSocket ->
	io:format("obtained data:~p ~n",[Bin]),
	gen_tcp:send(Socket,Bin),
	io:format("data resent~n"),
	{noreply, State}.

handle_cast({receive_broadcast,{From,Data}},State)->
	io:format("broadcast message=~p obtained!",[Data]),
	gen_tcp:send(State#state.playerSocket,Data),
	{noreply, State};
	
handle_cast({send_broadcast,{From,Data}},State)->
	io:format("broadcast message=~p sent!",[Data]),
	table:send_broadcast(State#state.pidofTable,{send_broadcast,{self(),Data}}),
	{norepyl,State}.

