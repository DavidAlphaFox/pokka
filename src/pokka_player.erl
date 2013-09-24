-module(pokka_player).
-behaviour(gen_fsm).
-export([start_link/2, startup/2]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

-record(state, {socket, name, table}).

start_link(Socket, Table) ->
  gen_fsm:start_link(?MODULE, [Socket, Table], []).

init(StateData) ->
  gen_fsm:send_event(self(), accept),
  {ok, startup, StateData}.

startup(accept, [ListenSocket, Table]) ->
  {ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
  Name = 'some body',
  Player = {Name, self()},
  pokka:join_table(Table, Player),
  {next_state, join, #state{socket=AcceptSocket, name=Name, table=Table}}.

handle_event({message, Message}, StateName, StateData) ->
  io:format("~p", [Message]),
  {next_state, StateName, StateData};

handle_event(_E, StateName, StateData) ->
  {next_state, StateName, StateData}.

handle_sync_event(_E, _From, StateName, StateData) ->
  {next_state, StateName, StateData}.

handle_info(E, StateName, StateData) ->
  io:format("unexpected: ~p~n", [E]),
  {next_state, StateName, StateData}.

code_change(_OldVsn, _StateName, StateData, _Extra) ->
  {ok, StateData}.

terminate(_Reason, _StateName, _StateData) ->
  io:format("terminate reason: ~p~n", [_Reason]).
