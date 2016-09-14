class App::WS::MessageControllers::Test

  def initialize(@message, @connection, @context)

  end

  def index
    @connection.print "all working!"
  end

end
