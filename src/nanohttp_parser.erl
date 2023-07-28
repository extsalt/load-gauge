-module(nanohttp_parser).

-export([parse_body/1, parse_headers/1, get_method/1, get_content_length/1]).

parse_headers(Request) -> ok.

parse_body(Request) -> ok.

get_method(Request) ->
  [RL | _] = Request,
  {_, M, _, _} = RL,
  M.

request_line_separator() -> <<"\r\n">>.
body_separator() -> <<"\r\n\r\n">>.

get_content_length(L) ->
  [_ | H] = L,
  get_content_length(H, 'Content-Length').

get_content_length(L, 'Content-Length') ->
  T = fun({http_header, _, _, AH, _}) ->
    case AH of
      "Content-Length" -> true;
      _ -> false
    end
      end,
  CL = lists:filter(T, L),
  case CL of
    [] -> {error, not_found};
    _ ->
      [H1| _] = CL,
      {http_header, _, _, _, N} = H1,
      {ok, N}
  end.