class Shepherd::Server::Router::WS::StringMessage

  INSTANCE = new


  protected def self.instace
    INSTANCE
  end

  @owner : Shepherd::Server::Handlers::WS::ConnectionEntryBase

  def initialize(@owner : Shepherd::Server::Handlers::WS::ConnectionEntry)
  end



  def process_message(message : String,
                      context : HTTP::Server::Context,
                      connection : HTTP::WebSocket) : Nil

    route_name, payload = split_route_and_payload(message)
    #finds route on RoutesMap (radix tree)
    route_handler = Shepherd::Router::WS::Map.instance.find_route( route_name )

    #calls the appropriate controller for route
    dispatch_route(route_handler, payload, context, connection)

    #TODO: think of better way of handling exceptions
    rescue ex : Exception
      puts ex.message
  end




  def dispatch_route(route_handler : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC),
                     payload : String,
                     context : HTTP::Server::Context,
                     connection : HTTP::WebSocket) : Nil

    if route_handler.found?
      route_handler.payload.call( connection, context, payload )
    else
      connection.print "not found"
    end

  end

  def split_route_and_payload(message)
    {message, message}
  end

end
