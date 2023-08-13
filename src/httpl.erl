-module(httpl).

%% API exports
-export([main/1, write_same_line/1]).

main(Args) ->
  nanohttp:start(8008),
  erlang:halt(0).


write_same_line(Message) ->
    io:format("\x1B[1A\x1B[K~s~n", [Message]).
