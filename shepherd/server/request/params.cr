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
  #lazy
  @multipart_form : Hash(String, String | Shepherd::Server::Request::MultipartFileWrapper) | Nil
  #lazy
  @body_gets_to_end_contents : String | Nil

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
  def body : IO?
    @context_request.body
  end

  def body_as_string : String
    if @body_gets_to_end_contents
      @body_gets_to_end_contents.as(String)
    else
      @body_gets_to_end_contents = @context_request.body.as(IO).gets_to_end
      @body_gets_to_end_contents.to_s
    end
  end

  #parses via HTTP::Params parse if headers include url_endoded_form else
  #returns empty HTTP::Params instance
  def encoded_form : HTTP::Params
    @encoded_form ||= Shepherd::Server::Request::UrlEncodedFormParser.parse(@context_request, self)
  end


  #accesses mutlripart and returns parsed hash of field => data pairs #
  def multipart_form : Hash(String, Shepherd::Server::Request::MultipartFileWrapper | String)
    @multipart_form ||= Shepherd::Server::Request::MultipartFormParser.parse(@context_request, self)
  end


  #returns url query params or empty HTTP::Params
  def uri_query : HTTP::Params
    @context_request.query_params
  end


  #will call appropriate parses depending on content type in request's Content-Type
  def self.parse(context_request : HTTP::Request) : (HTTP::Params | Hash(String, String) | JSON::Any | Hash(String, Shepherd::Server::Request::MultipartFileWrapper | String))
    headers = context_request.headers["Content-Type"]?.to_s
    if headers.includes? "multipart/form-data"
      self.new(context_request).multipart_form
    elsif headers.includes? "application/json"
      self.new(context_request).json
    elsif headers.includes? "application/x-www-form-urlencoded"
      self.new(context_request).encoded_form
    else
      Hash(String, String).new
    end
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
