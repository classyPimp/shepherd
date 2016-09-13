class Routes::Map < Shepherd::Router::Drawer

  def self.draw

    #block is of Shepherd::TypeAliases::ROUTE_HANDLER_PROC type (HTTP::Server::Context -> Void)
    Shepherd::Router::RoutesMap.instance.add_route( "get", "/") do |context|
      App::Controller::Test.new(context).index
    end


    Shepherd::Router::RoutesMap.instance.add_route( "get", "/id") do |context|
      App::Controller::Test.new(context).foo
    end



    Shepherd::Router::RoutesMap.instance.add_route( "get", "/ws" ) do |context|

      App::Controller::WSConnect.new(context).connect

    end


  end

end
