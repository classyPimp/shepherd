class Shepherd::Server::Handlers::Main < HTTP::Handler


  INSTANCE = new


  def self.instace
    INSTANCE
  end


  @websocket_handlers : Array(Shepherd::Server::Handlers::WS::ConnectionEntry)


  def initialize
    @websocket_handlers = Shepherd::Server::Handlers::WS::ConnectionEntry.registered_handlers
    set_websocket_handlers_next
  end



  def set_websocket_handlers_next : Nil
    Shepherd::Server::Handlers::WS::ConnectionEntry.registered_handlers.each do |handler|
      handler.set_next(@next)
    end
  end



  def call(context : HTTP::Server::Context) : Nil
    process_request(context)
  end



  def process_request(context : HTTP::Server::Context) : Nil
    #finds route on RoutesMap (radix tree)
    route_handler = Shepherd::Router::Http::Map.instance.find_route( context.request.method , context.request.path )

    #copies the param to context.request for later usage, e.g. accessing the
    #["user_id"] (#route_params on Server::Requst is added via monkey patch, refer there (CoreExtensions))
    transfer_route_params(from: route_handler, to: context.request )

    #calls the appropriate controller for route
    dispatch_route(route_handler, context)

    #if middleware has some after going handlers call them
    #TODO: decide if there should be? if so - uncomment
    # if next_handler = @next
    #   next_handler.call(context)
    # end

    #TODO: think of better way of handling exceptions
    rescue ex : Exception
      puts ex.message
  end



  #if route is on map, calls the appropriate controller with action
  #if not calls the 404 resposible controller
  def dispatch_route(route_handler : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC), context : HTTP::Server::Context) : Nil

    if route_handler.found?
      route_handler.payload.call( context )
    else
      Shepherd::Controller::Response404.new( context ).index
    end

  end


  #copies the Radix::Result #params to request, to make it available there
  def transfer_route_params(*, from : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC), to : HTTP::Request )
    to.route_params = from.params
  end



end
