class App::Controller::WSConnect < Shepherd::Controller::Base

  @@ws_handler : Shepherd::Server::WebsocketRouteHandler
  @@ws_handler = self.build_handler


  def initialize( @context : HTTP::Server::Context )
  end


  def self.build_handler : Shepherd::Server::WebsocketRouteHandler

    Shepherd::Server::WebsocketRouteHandler.new do |socket, context|

      puts "connected"

      socket.on_message do |message|
        puts message
      end

    end

  end


  def connect

    @@ws_handler.call( @context )

  end



  def disconnect(connection : HTTP::WebSocket)

    connection.close

  end



end
