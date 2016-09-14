#this class is responsible for returning array of HTTP::Handler wich
#will be passed to server initialization. So just write your own handler
#and paste an instance of it in here
#HANDLERS will be passed in this exact order
class Initializers::Middleware

  HANDLERS = [

    Shepherd::Server::Handlers::Main.new

  ] of HTTP::Handler


end
