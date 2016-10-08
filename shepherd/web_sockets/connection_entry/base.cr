class Shepherd::WebSockets::ConnectionEntry::Base

  # well socket handling is a bit tricky, and while I was writing it mindfucked
  # me as the "inception" movie
  #
  # Concept is:
  # app can have separate distinct websocket connection entries, e.g. one is general - which is responsible
  # for json exchange, and others for any other staff (some protected connection, or even maybe you will
  # write the voice transmition and etc). Most apps will have only on connection entry.
  #
  # Each connection has it's own handlers for the incoming messages it recieves after the connection established.
  # So in broad sense, the connection entry point is just another sort of hhtp route handler (the request comes with get header)
  # but when the connection established, it has it's own parralel listening to the messages it recieves, and has the speialied for that
  # connection type handlers.
  # So it's like server in server.
  #
  # to get it easier, just imagine that you would have some controller that is responsible for first user entry
  # later on you will have the special routing and controllers specific to that users.
  # same here ConnectionEntry (you can think of it as connection type), has it's own routing which will call own
  # controllers when something is passed as message through that connections
  #
  # What hapens when you add it to some http routing point:
  # itinstantiate --- own route map = on instantiation route map will just be there for you to add routes to it which in result will have a proc with whatever you pass to it, but supposed to recive
  #              |     some controller action
  #              |
  #              | --- own message handler = which has the #process_message which will be called when message recieved through connection
  #              |                           and which is passed to WebSocket#on_message block after connection#call is called---------------
  #              |                                                                                                                          |
  #              |---- own connection handler = which will have in it's proc this class' #on_connection_request_callback.     has the #call, which will mount the message handler for connection
  #                                                                                           |                               and which when called will establich connection
  # It has:                                                       |----------------------------                                              |
  #                                                               |                                                                          |
  # #on_connection_request -- responsible for calling the own connection handlers call                                                       |
  #                           and which is passed in block when connection handler instantiated,                                             |
  #                           it is expected to call #connect, which in turn calls the #call on connecion hadler-----------------------------|
  #                                                                                                                                          |
  #                                                                              |------------------------------------------------------------
  # #after_connect_callback -- which will be passed to WS#on_message callback afer, and which is reponsible to calling own message handler #process_message


  #This class is singleton
  macro inherited
    INSTANCE = new
  end

  def self.instance
    INSTANCE
  end

  #instance of connection handler will be responsible for connection request.
  #should keep in mind that instance is barely relies this class#on_connection_request
  ##on_connection_request is passed to block that is added to main http router map
  @incoming_connection_handler : Shepherd::Server::Handlers::WebSocket::Connection

  #Each connection has it's own map, instead of building scopes all the time in one big ws route map
  @ws_map_for_this_connection : Shepherd::Router::WebSocket::Map

  #this instance has the #process_message. After connection established, to connection#on_message block
  #this var's #proccess_message is passed
  @message_handler_for_this_connection_entry : Shepherd::Server::Handlers::WebSocket::StringMessage




  private def initialize

    @ws_map_for_this_connection = Shepherd::Router::WebSocket::Map.new
    #why string message? the mesage handler is pluggable, you can write your own for e.g. some realtime streaming and etc
    @message_handler_for_this_connection_entry = Shepherd::Server::Handlers::WebSocket::StringMessage.new(
      #message handler relyes on finding the route on this connections route map
      @ws_map_for_this_connection
    )

    #it does instantiate it, and passes to it's proc own after_connect_callback method, which will be called
    #when server will recieve ws connection request (on specific routing point)
    @incoming_connection_handler = build_connection_handler
  end



  #it does instantiate it, and passes to it's proc own after_connect_callback method, which will be called
  #when server will recieve ws connection request (on specific routing point)
  def build_connection_handler : Shepherd::Server::Handlers::WebSocket::Connection

    Shepherd::Server::Handlers::WebSocket::Connection.new do |socket, context|

      after_connect_callback(socket, context)

    end

  end




  #this method is will be called in connection handler, it's purpose is to dipatch the message handler
  def after_connect_callback(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

    #for now __on_connection_established__ calls on_connection_established, maybe later app will need
    #to perform some app specific stuff on connection
     __on_connection_established__(socket, context)

     socket.on_message do |message|

       #finds route and calls it's result (MEssagehandler controller)
       @message_handler_for_this_connection_entry.process_message(socket, context, message)

     end

     socket.on_close do |message|

       __on_connection_closing__(socket, context)

     end

  end


  #this is default, but supposed that user overrides it, for e.g. checking ath and etc.
  #example: connect(context) if current_user.roles.is_admin?
  #or simply return nothing (or reject) and no connection will be established
  def on_connection_request(context : HTTP::Server::Context) : Nil
    connect(context)
  end


  #when connect is called, the #after_connect_callback will be run
  #since that point, connection is considered established
  def connect(context : HTTP::Server::Context) : Nil
    @incoming_connection_handler.call(context)
  end


  #should be called in #on_connection_request
  def reject(context : HTTP::Server::Context) : Nil
    context.response.status_code = 401
  end


  #getter for route map, returns instace of ws map for this connection entry instance
  def route_map : Shepherd::Router::WebSocket::Map
    @ws_map_for_this_connection
  end


  def __on_connection_established__(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil
    on_connection_established(socket, context)
  end


  #serves as callback in user defined connection entry
  #will be called as soon as #connect caused WS handler to #call, this method is n WS @proc body
  def on_connection_established(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

  end


  #serves as callback in user defined connection entry
  #will be called as soon as WS handler starts to disconnect, this method is n WS @proc body
  #should be used for e.g. cleanup and etc.
  def __on_connection_closing__(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil
    on_connection_closing(socket, context)
  end

  def on_connection_closing(socket : HTTP::WebSocket, context : HTTP::Server::Context) : Nil

  end


  #TODO: probably should be deleted
  # def disconnect(connection : HTTP::WebSocket)
  #
  #   connection.close
  #
  # end

end
