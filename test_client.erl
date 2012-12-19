-module(test_client).
-compile(export_all).
-behaviour(gen_server).
-record(state,{playerSocket}).
-export([handle_cast/2,handle_info/2,handle_call/3]).
start(Port)->
	{ok,Pid} = gen_server:start(?MODULE, [Port], []).
	%io:format("~p~n",[Pid]).
	
send(Pid,Data)->
	gen_server:cast(Pid,{send_data,Data}).
 
init([Port]) ->
	{ok,PlayerSocket}=gen_tcp:connect(localhost,Port,[binary,{packet,0},{reuseaddr,true},{active,true}]),
	{ok, #state{playerSocket=PlayerSocket}}.

%% We never need you, handle_call!
handle_call(_E, _From, State) ->
{noreply, State}.

handle_info({tcp, Socket, Bin},State) when Socket=:=State#state.playerSocket ->
	io:format("obtained data:~p ~n",[Bin]),
	{noreply, State}.
	
handle_cast({send_data,Data},State)->
	io:format("get send request~n"),
	gen_tcp:send(State#state.playerSocket,Data),
	io:format("Sent data!~n"),
	{noreply, State}.
