require "radix"

class Shepherd::Router::WebSocket::Map


  @routes_map : Radix::Tree(Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC)


  def initialize
    @routes_map = Radix::Tree(Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC).new
  end



  def add_route(path : String, &handler : Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC) : Nil
    @routes_map.add path, handler
  end


  def find_route(path : String) : Radix::Result(Shepherd::TypeAliases::WS_MESSAGE_HANDLER_PROC)
    @routes_map.find path
  end


end
