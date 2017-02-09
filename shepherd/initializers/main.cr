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
    set_server_handlers
    draw_routes
    initialize_server_with_handlers
    start_server

  end


  # parses CLI commands, and sets them on corresponding configuration
  def parse_and_set_cli_options : Nil
    #accesses singleton
    Shepherd::Configuration::Services::CliToConfigTransmitter.transmit_cli_options(
      Shepherd::Configuration::CliParser.instance.options_passed_from_cli
    )

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
      Shepherd::Configuration::Server.instance.get_host,
      Shepherd::Configuration::Server.instance.get_port,
      Shepherd::Server::HandlersSetup.instance.handlers.not_nil!
    )
  end


  #starts server, passing args from corresponding configuration class
  def start_server : Nil

    puts "Shepherd is ready to serve:"
    puts "port: #{Shepherd::Configuration::Server.instance.get_port}"
    puts "host: #{Shepherd::Configuration::Server.instance.get_host}"

    @server.as(HTTP::Server).listen

  end


end
