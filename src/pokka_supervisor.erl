-module(pokka_supervisor).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local,?MODULE}, ?MODULE, []).

init([]) ->
  {ok, {
    {one_for_one, 3, 30},
    [
      {
        pokka_table_supervisor,
        {pokka_table_supervisor, start_link, []},
        permanent,
        6000,
        supervisor,
        [pokka_table_supervisor]
      },
      {
        pokka_player_supervisor,
        {pokka_player_supervisor, start_link, []},
        permanent,
        10000,
        supervisor,
        [pokka_player_supervisor]
      }
    ]}
  }.