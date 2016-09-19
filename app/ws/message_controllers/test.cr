class App::WS::MessageControllers::Test

  def initialize(@connection : HTTP::WebSocket, @context : HTTP::Server::Context, @message : String)
  end

  def index
    @connection.send "all working!"
  end

  def self.echo(connection : HTTP::WebSocket, context : HTTP::Server::Context, message : String)
    connection.send("foo")
  end

end
