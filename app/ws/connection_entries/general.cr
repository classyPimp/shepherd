class App::WS::ConnectionEntries::General < Shepherd::WebSockets::ConnectionEntry::Base


  def on_connection_request(context : HTTP::Server::Context) : Nil
    connect(context)
  end


  def on_connection_established(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

  end

  def on_connection_closing(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

  end

end
