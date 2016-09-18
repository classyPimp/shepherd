class App::WS::MessageControllers::Test

  def initialize(@connection : HTTP::WebSocket, @context : HTTP::Server::Context, @message : String)
  end

  def index
    @connection.send "all working!"
  end


end
