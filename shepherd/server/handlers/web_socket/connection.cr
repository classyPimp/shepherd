class Shepherd::Server::Handlers::WebSocket::Connection < HTTP::WebSocketHandler


  @@registered_handlers = [] of Shepherd::Server::Handlers::WebSocket::Connection


  protected def self.registered_handlers : Array(Shepherd::Server::Handlers::WebSocket::Connection)
    @@registered_handlers
  end



  def initialize(&@proc : Shepherd::TypeAliases::WS_CONNECTION_ENTRY_PROC)

    @@registered_handlers << self

  end

  #TODO: type arg
  def set_next(handler) : Nil

    @next = handler

  end


end
