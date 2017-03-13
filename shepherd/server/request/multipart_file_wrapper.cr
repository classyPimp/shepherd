require "tempfile"
class Shepherd::Server::Request::MultipartFileWrapper

  getter tmp_file : Tempfile
  getter meta : HTTP::FormData::FileMetadata
  getter headers : HTTP::Headers

  def initialize(*, io, meta, headers)
    @meta = meta
    @headers = headers
    @tmp_file = ::Tempfile.new("foo")
    ::File.open(@tmp_file.path, "w") do |file|
      IO.copy(io, file)
    end
  end

  def save(*, to dir : String, as file_name : String)
    File.open("#{dir}/#{file_name}", "w") do |file|
      IO.copy(tmp_file, file)
    end
    @tmp_file.unlink
  end

end
