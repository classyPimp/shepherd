class Shepherd::TypeAliases

  alias ROUTE_HANDLER_PROC = HTTP::Server::Context -> Nil

  alias WS_CONNECTION_ENTRY_PROC = HTTP::WebSocket, HTTP::Server::Context -> Nil

  alias WS_MESSAGE_HANDLER_PROC = HTTP::WebSocket, HTTP::Server::Context, String -> Nil

end
