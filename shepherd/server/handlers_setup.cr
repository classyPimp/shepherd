require "http"

class Shepherd::Server::HandlersSetup

  INSTANCE = new

  protected def self.instance
    INSTANCE
  end

  getter :handlers
  @handlers : Array(HTTP::Handler) | Nil


  def initialize

  end

  def set_handlers(handlers : Array(HTTP::Handler))
    @handlers = handlers
  end


end
