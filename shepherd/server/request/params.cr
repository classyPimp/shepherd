require "json"

#class responsible for fetching different "params" types and
#dispatching to appropriate parsers if needed
class Shepherd::Server::Request::Params


  @context_request : HTTP::Request
  #lazy
  @json : JSON::Any | Nil
  #lazy
  @query : HTTP::Params | Nil
  #lazy
  @encoded_form : HTTP::Params | Nil



  def initialize(context_request : HTTP::Request)
    @context_request = context_request
  end

  #parses body for JSON if Content-Type is /json else returns empty JSON::Any
  def json : JSON::Any
    @json ||= (Shepherd::Server::Request::JsonParser.parse(@context_request))
  end

  #returns the radix result params; this param is assigned to context.request
  #in main handler after the route (radix path) is found
  #route_params property is added through monkey patch to HTTP::Request
  def route : Hash(String, String)
    @context_request.route_params
  end

  #returns the body
  def body : String?
    @context_request.body
  end

  #parses via HTTP::Params parse if headers include url_endoded_form else
  #returns empty HTTP::Params instance
  def encoded_form : HTTP::Params
    @encoded_form ||= Shepherd::Server::Request::UrlEncodedFormParser.parse(@context_request)
  end

  #returns url query params or empty HTTP::Params
  def url_query : HTTP::Params
    @context_request.query_params
  end


  #TODO: make typed json accessor
  def typed_json(args_name)

  end


  #TODO: generic params accessor, that will look everywhere. some struct with []
  #accessor which'll parse on initialize and return first found
  # e.g. in controller params.generic["id"]; params.generic["user"]
  def generic

  end


end
