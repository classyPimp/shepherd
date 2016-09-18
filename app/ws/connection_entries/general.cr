class App::WS::ConnectionEntries::General < Shepherd::WebSockets::ConnectionEntry::Base


  def self.on_connection_request(context : HTTP::Server::Context)
    connect
  end


end
