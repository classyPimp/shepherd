class Shepherd::Server::Handlers::Main

  include HTTP::Handler

  INSTANCE = new


  def self.instace
    INSTANCE
  end

  #web socket connection entries are not "pushed" in to middleware. instead they just exist independently,
  #and their instances are abstractly simply http route "results". But in order to simulate the middlewarenes of them
  # they are fetched in main handler and given the @next handler of main, so they can also call_next.
  @websocket_connection_entries : Array(Shepherd::Server::Handlers::WebSocket::Connection)


  def initialize
    #grabs the instances of prepared Ws handlers
    @websocket_connection_entries = Shepherd::Server::Handlers::WebSocket::Connection.registered_handlers
    set_websocket_handlers_next
  end


  #as ws handlers do not go in to middleware directly, but thy are still server handlers, to simulate their
  #middlewareness they are given a next if call_next for after handlers is necessary.
  def set_websocket_handlers_next : Nil
    Shepherd::Server::Handlers::WebSocket::Connection.registered_handlers.each do |handler|
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
    # rescue ex : Exception
    #   context.response.status_code = 500
    #   context.response.print ex
    #   context.response.print ex.backtrace
    #   context.response.print ex.callstack
  end



  #if route is on map, calls the appropriate controller with action
  #if not calls the 404 resposible controller
  def dispatch_route(route_handler : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC), context : HTTP::Server::Context) : Nil

    if route_handler.found?
      route_handler.payload.call( context )
    else
      #TODO: should send public/404.html file instead
      Shepherd::Controller::Response404.new( context ).index
    end

  end


  #copies the Radix::Result #params to request, to make it available there
  def transfer_route_params(*, from : Radix::Result(Shepherd::TypeAliases::ROUTE_HANDLER_PROC), to : HTTP::Request )
    to.route_params = from.params
  end



end
