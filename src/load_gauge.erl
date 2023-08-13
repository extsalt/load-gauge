-module(load_gauge).
-record(stats, {okResponse = 0, errorResponse = 0}).

%% API
-export([load_gauge_manager/0, load_gauge/3, http_request_reaper/3, make_get_request/2, stats_manager/1]).

%% make http request
make_get_request(Username, Url) ->
  inets:start(),
  Response = httpc:request(Url),
  parse_response(Username, Response).

%% http request parser
parse_response(Username, {ok, _}) -> list_to_atom(Username) ! {self(), http_ok};
parse_response(Username, {error, _}) -> list_to_atom(Username) ! {self(), http_nook}.

%% Http request reaper
http_request_reaper(_, 0, _) -> ok;
http_request_reaper(Username, 1, Url) ->
  spawn(fun() -> make_get_request(Username, Url) end);
http_request_reaper(Username, N, Url) ->
  spawn(fun() -> make_get_request(Username, Url) end),
  http_request_reaper(Username, N - 1, Url).

%%Stats manager
stats_manager(S) ->
  receive
    {From, http_ok} ->
      N = S#stats{okResponse = S#stats.okResponse + 1},
      From ! ok,
      stats_manager(N);

    {From, http_nook} ->
      N = S#stats{errorResponse = S#stats.errorResponse + 1},
      From ! ok,
      stats_manager(N);

    {From, get} ->
      From ! S,
      stats_manager(S);

    {From, done} ->
      From ! exit(self(), normal)
  end.

load_gauge(Username, Worker, Url) ->
%%  start stats manager
  M = #stats{okResponse = 0, errorResponse = 0},
  spawn(load_request, stats_manager, [M]),
  spawn(load_gauge, http_request_reaper, [Username, Worker, Url]).

%% Start http manager
%% http manager does:
%% 1. start http_request_reaper
%% 2. start stats manager

load_gauge_manager() ->
  receive
    {From, {gauge, Username, Url, Workers}} ->
      spawn_link(load_gauge, load_gauge, [Username, Workers, Url]),
      From ! {ok, Workers},
      load_gauge_manager();
    {From, _} -> From ! {error, "could not understand request"},
      load_gauge_manager()
  end.