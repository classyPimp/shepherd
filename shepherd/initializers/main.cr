require "http/server"
#singleton class, responsible for starting an application.
class Shepherd::Initializers::Main

  INSTANCE = new

  @server : HTTP::Server?
  #singleton accessor, serves as "main" function.
  def self.start_application
    INSTANCE.bootstrap
  end

  def initialize

  end
  #responsible for setting the configruration, initilizing user defined routes map, and server starting
  def bootstrap : Nil

    parse_and_set_cli_options
    run_env_config
    set_server_handlers
    draw_routes
    initialize_server_with_handlers
    connect_database
    start_server #unless TEST #TODO: SHOULD READ FROM ENV AND RUN IN THREAD IF IN TEST ENV
  end


  # parses CLI commands, and sets them on corresponding configuration
  def parse_and_set_cli_options : Nil
    #accesses singleton
    Shepherd::Configuration::Services::CliToConfigTransmitter.transmit_cli_options(
      Shepherd::Configuration::CliParser.instance.options_passed_from_cli
    )

  end


  def run_env_config : Nil
    Shepherd::Configuration::General.env.not_nil!.set_config
    puts "env: #{Shepherd::Configuration::General.env.class.name}"
  end


  def set_server_handlers : Nil
    Shepherd::Server::HandlersSetup.instance.set_handlers(::Initializers::Middleware::HANDLERS)
  end

  # parses user defined routes map and sets them
  def draw_routes : Nil
    #call accesses the singleton
    ::Routes::Map.instance.draw
  end


  def initialize_server_with_handlers : HTTP::Server
    @server = HTTP::Server.new(
      Shepherd::Configuration::Server.host.not_nil!,
      Shepherd::Configuration::Server.port.not_nil!,
      Shepherd::Server::HandlersSetup.instance.handlers.not_nil!
    )
  end


  #starts server, passing args from corresponding configuration class
  def start_server : Nil

    puts "Shepherd is ready to serve:"
    puts "port: #{Shepherd::Configuration::Server.port}"
    puts "host: #{Shepherd::Configuration::Server.host}"

    if Shepherd::Configuration::General.env.is_a?(::Config::Env::Test)
      spawn do
        @server.as(HTTP::Server).listen
      end
    else
      @server.as(HTTP::Server).listen
    end
  end


  def connect_database
    connection = DB.open(Shepherd::Configuration::Database.connection_address.not_nil!)
    Shepherd::Database::DefaultConnection.set_connection(connection)
  end

end
