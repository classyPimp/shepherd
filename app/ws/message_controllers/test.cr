class App::WS::MessageControllers::Test < Shepherd::WebSockets::MessageController::Base


  def index
    send "all working!"
  end

  def self.echo(connection : HTTP::WebSocket, context : HTTP::Server::Context, message : String)
    connection.send(message)
  end

end
