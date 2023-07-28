%% nano-http-server
%% supports - GET, POST (url-encoded-form-data)

-module(nanohttp).
-export([start/1]).

handle_request(Socket, R) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, http_eoh} ->
      L = lists:reverse(R),
%%      io:format("~p~n", [L]),
      case nanohttp_parser:get_method(L) of
        'GET' ->
          gen_tcp:send(Socket, <<"HTTP/1.1 200 OK\r\n\r\nGET">>),
          gen_tcp:close(Socket);

        'POST' ->
          case nanohttp_parser:get_content_length(L) of
            {ok, CL} ->
              io:format("~p~n", [CL]),
              {ByteCount, []} = string:to_integer(CL),
              inet:setopts(Socket, [{packet, raw}]),
              case gen_tcp:recv(Socket, ByteCount) of
                {ok, Body} ->
%%                  io:format("~p~n", [Body]),
                  BodyParams = uri_string:dissect_query(Body),
                  io:format("~p~n", [BodyParams]),
                  gen_tcp:send(Socket, <<"HTTP/1.1 200 OK\r\n\r\nPOST">>),
                  gen_tcp:close(Socket);
                {error, closed} -> error;
                {error, Reason} -> Reason
              end
          end
      end;

    {ok, Request} ->
      handle_request(Socket, [Request | R]);

    {error, Reason} ->
      io:format("Error: ~p~n", [Reason]),
      gen_tcp:close(Socket)
  end.

handle_client(LS) ->
  {ok, CS} = gen_tcp:accept(LS),
  P = spawn(fun() -> handle_request(CS, []) end),
  gen_tcp:controlling_process(CS, P),
  handle_client(LS).

start(Port) ->
  {ok, LS} = gen_tcp:listen(Port, [binary, {active, false}, {packet, http}]),
  handle_client(LS).