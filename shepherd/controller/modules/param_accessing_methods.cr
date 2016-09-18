module Shepherd::Controller::Modules::ParamAccessingMethods

  macro inherited

    #holds the class responsible for fetching different "params" types and
    #dispatching to appropriate parsers if needed
    @params : Shepherd::Server::Request::Params | Nil

  end


  #accesses the class responsible for fetching different "params" types and
  #dispatching to appropriate parsers if needed
  def params : Shepherd::Server::Request::Params
    @params ||= Shepherd::Server::Request::Params.new(@context.request)
  end


end
