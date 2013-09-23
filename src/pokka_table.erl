-module(pokka_table).
-behaviour(gen_fsm).
-export([start_link/1]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-export([idle/2]).
-record(state, {players=[]}).

start_link(Table) -> gen_fsm:start_link({local,Table}, ?MODULE, #state{}, []).

init(State) -> {ok, idle, State}.

idle({join, Player = {Name, _Pid}}, State) ->
  Players = State#state.players,
  AllPlayers = [Player|Players],
  send(AllPlayers, 'New player  ~p has joined.~n', [Name]),
  {next_state, idle, State#state{players=AllPlayers}, 5000}.

handle_event(_Event, StateName, State) -> {next_state, StateName, State}.

handle_sync_event(terminate, _From, _StateName, State) -> {stop, normal, ok, State};

handle_sync_event(_Event, _From, StateName, State) -> {reply, unknown, StateName, State}.

handle_info(_Message, StateName, State) -> {next_state, StateName, State}.

terminate(normal, _StateName, State) -> io:format("shutting down. state: ~p~n", [State]).

code_change(_OldVersion, StateName, State, _Extra) -> {ok, StateName, State}.

send([], _Str, _Args) -> ok;

send([{_Name, Pid}|Rest], Str, Args) ->
  gen_server:cast(Pid, io:format(Str, Args)),
  send(Rest, Str, Args).
