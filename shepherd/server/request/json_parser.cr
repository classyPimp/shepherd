require "json"

#Responsible for parsing request.body
class Shepherd::Server::Request::JsonParser


  APPLICATION_JSON = "application/json"



  def self.parse(request : HTTP::Request) : JSON::Any

    if !request.body.nil? && request.headers["Content-Type"]?.try(&.starts_with?(APPLICATION_JSON))
      return JSON.parse( request.body.as(String) )
    else
      return JSON::Any.new("")
    end

  rescue ex: Exception

    raise "#{ex.message} while parsing params.json, probably was called in some controller"

  end




end
