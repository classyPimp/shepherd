class Shepherd::Server::Request::UrlEncodedFormParser


  URL_ENCODED_FORM = "application/x-www-form-urlencoded"



  def self.parse(request : HTTP::Request) : HTTP::Params

    if !request.body.nil? && (request.headers["Content-Type"]? =~ /#{URL_ENCODED_FORM}/)
      HTTP::Params.parse(request.body.as(String))
    else
      HTTP::Params.parse("")
    end

  end



end
