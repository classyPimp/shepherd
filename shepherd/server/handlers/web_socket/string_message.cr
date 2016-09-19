#thish class will be a property of connection entry class
class Shepherd::Server::Handlers::WebSocket::StringMessage


  @route_map : Shepherd::Router::WebSocket::Map


  def initialize(@route_map : Shepherd::Router::WebSocket::Map)
  end


  #this method is called in #on_message block in WS HANDLER proc
  def process_message(connection : HTTP::WebSocket,
                      context : HTTP::Server::Context,
                      message : String
                      ) : Nil
    #splits message and payload from message that follows this convention
    # /foo|{payload: "bar"} (route path and payload must be delimeted by '|')
    route_name, payload = split_route_and_payload(message)
    #finds route on RoutesMap (radix tree) (that is a property in connectionentry (specific instance for it))
    route_handler = @route_map.find_route( route_name )

    #calls the appropriate controller for route
    dispatch_route(connection, context, payload, route_handler)

    #TODO: think of better way of handling exceptions
    rescue ex : Exception
      puts ex.message
  end



  #finds route corresponding to message path calling it result or sending "404"
  #though socket connection
  def dispatch_route(connection : HTTP::WebSocket,
                    context : HTTP::Server::Context,
                    payload : String,
                    route_handler : Radix::Result(Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC),
                    ) : Nil

    if route_handler.found?
      route_handler.payload.call( connection, context, payload )
    else
      connection.send "404"
    end

  end


  #splits message and payload from message that follows this convention
  # /foo|{payload: "bar"} (route path and payload must be delimeted by '|')
  # CAN ANYONE MAKE IT FASTER please?
  def split_route_and_payload(message) : Tuple(String, String)
    index = 0_i16
    found = false
    message.each_char do |char|
      if char == '|'
        found = true
        break
      else
        index += 1
      end
    end
    if found
    {
      message[0...index], #path
      message[index + 1..-1] #payload
    }
    else
      {"/echo", message}
    end
  end

end
