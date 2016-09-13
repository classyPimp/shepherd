class Shepherd::TypeAliases

  alias ROUTE_HANDLER_PROC = HTTP::Server::Context -> Nil

  alias WS_ROUTE_HANDLER_PROC = HTTP::WebSocket, HTTP::Server::Context -> Nil

end
