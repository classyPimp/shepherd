class Shepherd::Server::Request::MultipartFormParser

  def self.parse(request : HTTP::Request, owner : Shepherd::Server::Request::Params) : Hash(String, String | Shepherd::Server::Request::MultipartFileWrapper)

    value_to_return = {} of String => (String | Shepherd::Server::Request::MultipartFileWrapper)

    HTTP::FormData.parse(request) do |field, io, meta, headers|
      if headers["Content-Type"]?
        value_to_return[field] = Shepherd::Server::Request::MultipartFileWrapper.new(io: io, meta: meta, headers: headers)
      else
        value_to_return[field] = io.to_s
      end
    end

    value_to_return

  end

end
