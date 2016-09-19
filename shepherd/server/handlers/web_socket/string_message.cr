class Shepherd::Server::Handlers::WebSocket::StringMessage


  @route_map : Shepherd::Router::WebSocket::Map

  def initialize(@route_map : Shepherd::Router::WebSocket::Map)
  end



  def process_message(connection : HTTP::WebSocket,
                      context : HTTP::Server::Context,
                      message : String
                      ) : Nil

    route_name, payload = split_route_and_payload(message)
    #finds route on RoutesMap (radix tree)
    route_handler = @route_map.find_route( route_name )

    #calls the appropriate controller for route
    dispatch_route(connection, context, payload, route_handler)

    #TODO: think of better way of handling exceptions
    rescue ex : Exception
      puts ex.message
  end




  def dispatch_route(connection : HTTP::WebSocket,
                    context : HTTP::Server::Context,
                    payload : String,
                    route_handler : Radix::Result(Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC),
                    ) : Nil

    if route_handler.found?
      route_handler.payload.call( connection, context, payload )
    else
      connection.send "not found"
    end

  end

  def split_route_and_payload(message)

    index = 0_i8
    found = false
    message.each_char do |char|
      if char == '|'
        found = true
        break
      end
      index += 1
    end
    if found
    {
      message[0...index], #path
      message[index + 1..-1] #payload
    }
    else
      {"/echo", ""}
    end
  end

end
