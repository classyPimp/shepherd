class Shepherd::WebSockets::MessageController::Base

  def initialize(@connection : HTTP::WebSocket, @context : HTTP::Server::Context, @message : String)
  end


  #sends String value to ws
  def send(value : String) : Nil
    @connection.send(value)
  end

  #disconnects current connection
  def disconnect : Nil
    @connection.close
  end

end
