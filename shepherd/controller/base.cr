class Shepherd::Controller::Base



  @context : HTTP::Server::Context
  property :context

  #holds the class responsible for fetching different "params" types and
  #dispatching to appropriate parsers if needed
  @params : Shepherd::Server::Request::Params | Nil



  def initialize(context : HTTP::Server::Context)
    @context = context
  end


  #accesses the class responsible for fetching different "params" types and
  #dispatching to appropriate parsers if needed
  def params : Shepherd::Server::Request::Params
    @params ||= Shepherd::Server::Request::Params.new(@context.request)
  end


  #render plain like Rails does
  def render_plain(value : String) : Nil
    @context.response.print(value)
  end



end
