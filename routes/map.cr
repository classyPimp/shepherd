class Routes::Map < Shepherd::Router::Drawer

  def self.draw

    #block is of Shepherd::TypeAliases::ROUTE_HANDLER_PROC type (HTTP::Server::Context -> Void)
    Shepherd::Router::Http::Map.instance.add_route( "get", "/") do |context|
      App::Controller::Test.new(context).index
    end


    Shepherd::Router::Http::Map.instance.add_route( "get", "/id") do |context|
      App::Controller::Test.new(context).foo
    end


    Shepherd::Router::Http::Map.instance.add_route( "get", "/ws" ) do |context|

      App::WS::ConnectionEntries::General.on_connection_request(context)

    end


    App::WS::ConnectionEntries::General.route_map.add_route( "foo" ) do |connection, context, message|

      App::WS::MessageControllers::Test.new(message, connection, context).index

    end


  end

end
