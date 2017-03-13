module Shepherd::Controller::Modules::ParamAccessingMethods

  macro inherited

    #holds the class responsible for fetching different "params" types and
    #dispatching to appropriate parsers if needed
    @params : (HTTP::Params | Hash(String, String) | JSON::Any) #: Shepherd::Server::Request::Params | Nil
    @unparsed_params : Shepherd::Server::Request::Params | Nil

  end


  #will instantiate params parsing class and
  #depending on content type of the request
  #will parse appropriately and return parsed value
  #TODO: think of implementing interface if #[] #[]= for parsed results
  def params : (HTTP::Params | Hash(String, Shepherd::Server::Request::MultipartFileWrapper | String) | Hash(String, String) | JSON::Any)
    @params ||= Shepherd::Server::Request::Params.parse(@context.request)
  end

  def route_params
    @route_params ||= unparsed_params.route
  end

  def uri_query_params(args_name)
    @uri_query_params ||= unparsed_params.uri_query
  end
  #accesses the class responsible for fetching different "params" types and
  #dispatching to appropriate parsers if needed
  def unparsed_params : Shepherd::Server::Request::Params
    @unparsed_params ||= Shepherd::Server::Request::Params.new(@context.request)
  end


end
