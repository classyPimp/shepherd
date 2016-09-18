require "radix"

class Shepherd::Router::Http::Map


  INSTANCE = new

  #singleton accessor
  protected def self.instance
    INSTANCE
  end


  @routes_map : Radix::Tree(Shepherd::TypeAliases::ROUTE_HANDLER_PROC)


  def initialize
    @routes_map = Radix::Tree(Shepherd::TypeAliases::ROUTE_HANDLER_PROC).new
  end



  #adds route path with corresponding route handler proc to routes map (radix tree)
  def add_route(method : String, path : String, &handler : Shepherd::TypeAliases::ROUTE_HANDLER_PROC) : Nil

    node = convert_to_radix_path(method.upcase, path)
    @routes_map.add node, handler

  end


  #finds route on routes map (radix tree)
  def find_route(method : String, path : String) : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC)
    @routes_map.find convert_to_radix_path(method, path)
  end


  #TODO: refactor to using enums for HTTP methods
  def convert_to_radix_path(method : String, path : String) : String
    "/#{method}#{path}"
  end


end
