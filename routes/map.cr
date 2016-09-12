class Routes::Map < Shepherd::Router::Drawer

  def self.draw

    #block is of Shepherd::TypeAliases::ROUTE_HANDLER_PROC type (HTTP::Server::Context -> Void)
    Shepherd::Router::RoutesMap.instance.add_route( "post", "/:id") do |context|
      App::Controller::Test.new(context).index
    end

    Shepherd::Router::RoutesMap.instance.add_route( "get", "/:id") do |context|
      App::Controller::Test.new(context).index
    end

  end

end
