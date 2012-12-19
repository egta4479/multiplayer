-module(table).
-behaviour(gen_server).
-compile(export_all).
-record(state,{list_of_subscription=[]}).

start()->
	gen_server:start(?MODULE,[],[]).
	
init([])->
	{ok,#state{}}.
subscribe(PidofTable,Pid)->
	gen_server:cast(PidofTable,{subscribe,Pid}).

unsubscribe(PidofTable,Pid)->
	gen_server:cast(PidofTable,{unsubscribe,Pid}).
		
send_broadcast(PidofTable,Message={send_broadcast,{_From,_Data}})->
	gen_server:cast(PidofTable,Message).

handle_cast({subscribe,Pid},State)->
	List_of_subscription=State#state.list_of_subscription++[Pid],
	{noreply,State#state{list_of_subscription=List_of_subscription}};
	
handle_cast({unsubscribe,Pid},State)->
	List_of_subscription=State#state.list_of_subscription--[Pid],
	{noreply,State#state{list_of_subscription=List_of_subscription}};
	
handle_cast({send_broadcast,{From,Data}},State)->
	[player:receive_broadcast(Pid,{receive_broadcast,{From,Data}}) ||  Pid<-State#state.list_of_subscription, Pid=/=From],
	{noreply,State}.
	
