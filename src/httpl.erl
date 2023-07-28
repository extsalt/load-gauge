-module(httpl).

%% API exports
-export([main/1, write_same_line/1, parse_http_response/1]).

main(Args) ->
  nanohttp:start(8008),
  erlang:halt(0).
%%  inets:start(),
%%  Result = httpc:request(Args),
%%  parse_http_response(Result),

parse_http_response({ok, Result}) ->
  {StatusLine, Headers, Body} = Result,
  io:format("StatusLine ~p~n", [StatusLine]),
  io:format("Headers ~p~n", [Headers]),
  io:format("Body ~p~n", [Body]),
  {_, StatusCode, _}  = StatusLine,
  io:format("Status Code ~p~n", [StatusCode]),
  ok;

parse_http_response({error, Result}) ->
  io:format("~p~n", [Result]).

write_same_line(Message) ->
    io:format("\x1B[1A\x1B[K~s~n", [Message]).
