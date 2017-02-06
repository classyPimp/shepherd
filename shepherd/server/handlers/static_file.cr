
# This handler repeats some the functionality of StaticFileHandler/
# the reason why not use that, is that it does unnecessary work around responsing with Dir listing
# this class sole responsibility: if file exists and  is GET and path is not /, send it
# This should be used only for development, in other cases you will anyway use proxy server as NGINX for example
# and if you need serving file from app (e.g. proptected file) send it via x_send_file(file) to cause your server send it.
class Shepherd::Server::Handlers::StaticFile

  include HTTP::Handler

  #serves as dir from where files should be served
  @public_dir : String



  def initialize(public_dir : String)
    @public_dir = File.expand_path public_dir
  end




  def call(context : HTTP::Server::Context) : Nil


    #checks for correct method and that path is not / ; else early returns
    unless (context.request.method == "GET" || context.request.method == "HEAD") && context.request.path != "/"
      call_next(context)

    else

      original_path = context.request.path
      request_path = URI.unescape(original_path)
      expanded_path = File.expand_path(request_path)

      file_path = File.join(@public_dir, expanded_path)

      puts file_path

      if File.exists?(file_path)
        context.response.content_type = mime_type(file_path)
        context.response.content_length = File.size(file_path)

        File.open(file_path) do |file|
          IO.copy(file, context.response)
        end

      else

        call_next(context)

      end

    end

  end


  # def call_next(context : HTTP::Server::Context) : Nil
  #   @next.call(context)
  # end


  #REFACTOR TO USE SERVER::MIMETYPES
  private def mime_type(path)
    case File.extname(path)
    when ".txt"          then "text/plain"
    when ".htm", ".html" then "text/html"
    when ".css"          then "text/css"
    when ".js"           then "application/javascript"
    else                      "application/octet-stream"
    end
  end


end
