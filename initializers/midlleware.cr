#this class is responsible for returning array of HTTP::Handler wich
#will be passed to server initialization. So just write your own handler
#and paste an instance of it in here
#HANDLERS will be passed in this exact order
class Initializers::Middleware

  HANDLERS = [

    #HTTP::LogHandler.new,
    #HTTP::StaticFileHandler.new(Config::Application::PUBLIC_DIR),
    #for serving files in develepment env you can use this handler
    Shepherd::Server::Handlers::StaticFile.new(Config::Application::PUBLIC_DIR),
    Shepherd::Server::Handlers::Main.new

  ] of HTTP::Handler


end
