class App::WS::ConnectionEntries::General < Shepherd::Controller::WS::ConnectionEntryBase


  def on_connection_request(context : HTTP::Server::Context)
    connect
  end


end
