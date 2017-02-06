class Shepherd::Server::Request::UrlEncodedFormParser


  URL_ENCODED_FORM = "application/x-www-form-urlencoded"



  def self.parse(request : HTTP::Request, owner : Shepherd::Server::Request::Params) : HTTP::Params

    if !request.body.nil? && (request.headers["Content-Type"]?.to_s.includes? URL_ENCODED_FORM)
      HTTP::Params.parse(owner.body_as_string)
    else
      HTTP::Params.parse("")
    end

  end



end
