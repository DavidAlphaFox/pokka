-module(pokka_table).
-behaviour(gen_fsm).
-export([start/0, start_link/1]).
-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).
-export([idle/3]).
-record(state, {players=[]}).
-record(player, {name, pid}).

start() -> gen_fsm:start(?MODULE, #state{}, []).

start_link(Table) -> gen_fsm:start_link({local,Table}, ?MODULE, #state{}, []).

init(State) -> {ok, idle, State}.

idle({join, Name, Pid}, _From, State) ->
  Players = State#state.players,
  Player = #player{name=Name, pid=Pid},
  NewState = State#state{players=[Player|Players]},
  send_all(Players, "status: new player " ++ atom_to_list(Name) ++ " joined the table"),
  {reply, ok, idle, NewState}.

handle_event({leave, Name, Pid}, StateName, StateData) ->
  Player = #player{name=Name, pid=Pid},
  Players = lists:delete(Player, StateData#state.players),
  NewStateData = StateData#state{players=Players},
  send_all(Players, "status: player " ++ atom_to_list(Name) ++ " left the table"),
  {next_state, StateName, NewStateData};

handle_event(_Event, StateName, State) -> {next_state, StateName, State}.

handle_sync_event(terminate, _From, _StateName, State) -> {stop, cancelled, ok, State};

handle_sync_event(_Event, _From, StateName, State) -> {reply, unknown, StateName, State}.

handle_info(_Message, StateName, State) -> {next_state, StateName, State}.

terminate(normal, _StateName, State) -> io:format("shutting down. state: ~p~n", [State]).

code_change(_OldVersion, StateName, State, _Extra) -> {ok, StateName, State}.

send_all([], _Message) -> ok;

send_all([Player|Rest], Message) ->
  gen_fsm:send_all_state_event(Player#player.pid, {status, Message}),
  send_all(Rest, Message).
