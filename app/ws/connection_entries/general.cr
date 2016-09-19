class App::WS::ConnectionEntries::General < Shepherd::WebSockets::ConnectionEntry::Base


  def self.on_connection_request(context : HTTP::Server::Context) : Nil
    connect
  end


  def on_connection_established(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

  end


end
