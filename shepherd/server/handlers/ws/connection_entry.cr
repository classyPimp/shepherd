class Shepherd::Server::Handlers::WS::ConnectionEntry < HTTP::WebSocketHandler


  @@registered_handlers = [] of Shepherd::Server::Handlers::WS::ConnectionEntry


  protected def self.registered_handlers : Array(Shepherd::Server::Handlers::WS::ConnectionEntry)
    @@registered_handlers
  end



  def initialize(&@proc : Shepherd::TypeAliases::WS_CONNECTION_ENTRY_PROC)

    Shepherd::Server::Handlers::WS::ConnectionEntry.registered_handlers << self

  end


  def set_next(handler) : Nil

    @next = handler

  end


end
