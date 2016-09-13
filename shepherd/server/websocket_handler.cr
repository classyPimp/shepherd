class Shepherd::Server::WebsocketRouteHandler < HTTP::WebSocketHandler


  @@registered_handlers = [] of Shepherd::Server::WebsocketRouteHandler


  protected def self.registered_handlers : Array(Shepherd::Server::WebsocketRouteHandler)
    @@registered_handlers
  end



  def initialize(&@proc : Shepherd::TypeAliases::WS_ROUTE_HANDLER_PROC)

    Shepherd::Server::WebsocketRouteHandler.registered_handlers << self
    
  end


  def set_next(handler) : Nil

    @next = handler

  end


end
