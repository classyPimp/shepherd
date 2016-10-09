class Routes::Map < Shepherd::Router::Drawer

  def draw

    scope "/benchmark" do

      get "/functional", to: "test.functional"

      get "/instantial", to: "test#instantial"

    end

    get "/", to: "test#home"

    resources "test"

    #get "/", to: "test#index"
#
    ws_connection "/ws", to: "general" do

      msg "/echo", to: "test.echo"

      msg "/foo", to: "test#index"

      scope "/bar" do

        msg "/baz", to: "test#index"

      end

    end
    #resources "test"
    # Shepherd::Router::Http::Map.instance.add_route( "put", "/test/:id") do |context|
    #   App::Controllers::Test.new(context).update
    # end
    # #block is of Shepherd::TypeAliases::ROUTE_HANDLER_PROC type (HTTP::Server::Context -> Void)
    # Shepherd::Router::Http::Map.instance.add_route( "get", "/") do |context|
    #   App::Controller::Test.new(context).index
    # end
    #
    # ws_connection "general" do
    #   "foo", to: "test#index"
    # end
    # Shepherd::Router::Http::Map.instance.add_route( "get", "/id") do |context|
    #   App::Controller::Test.new(context).foo
    # end
    #
    #
    #
    #
    # general_ws_con = App::WS::ConnectionEntries::General::INSTANCE
    #
    # Shepherd::Router::Http::Map.instance.add_route( "get", "/ws" ) do |context|
    #
    #   general_ws_con.on_connection_request(context)
    #
    # end
    #
    # general_ws_con.route_map.add_route( "foo" ) do |connection, context, payload|
    #
    #   App::WS::MessageControllers::Test.new(connection, context, payload).index
    #
    # end





  end

end
