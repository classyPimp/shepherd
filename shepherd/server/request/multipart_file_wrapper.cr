class Shepherd::Server::Request::MultipartFileWrapper

  getter io : IO::Delimited
  getter meta : HTTP::FormData::FileMetadata
  getter headers : HTTP::Headers

  def initialize(*, io, meta, headers)
    @io = io
    @meta = meta
    @headers = headers
  end

end
