class Shepherd::Controller::WS::ConnectionEntryBase

  macro inherited

    @@ws_handler : Shepherd::Server::Handlers::WS::ConnectionEntry
    @@ws_handler = self.listen

    @@ws_map_for_this_connection_entry : Shepherd::Server::Router::WS::Map
    @@ws_map_for_this_connection_entry = Shepherd::Server::Router::WS::Map.new

    @@message_handler_for_this_connection_entry : Shepherd::Server::Handlers::WS::StringMessage
    @@message_handler_for_this_connection_entry = Shepherd::Server::Handlers::WS::StringMessage.new(self)

    #for test purpose only TODO: delete
    def self.route_map
      @@ws_map_for_this_connection_entry = Shepherd::Server::Router::WS::Map.new
    end

  end



  private def self.listen : Shepherd::Server::Handlers::WS::ConnectionEntry

    Shepherd::Server::Handlers::WS::ConnectionEntry.new do |ws_connection, context|

      ws_connection.on_message do |message|

        @@message_handler_for_this_connection_entry.process_message(message, context, ws_connection)

      end

    end

  end


  def self.on_connection_request(context : HTTP::Server::Context)

  end

  def self.connect(context : HTTP::Server::Context) : Nil
    @@ws_handler.call
  end

  #TODO: probably should be deleted
  # def disconnect(connection : HTTP::WebSocket)
  #
  #   connection.close
  #
  # end

end
