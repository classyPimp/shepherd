module Shepherd::Controller::FunctionalModules::RenderingMethods

  def render(context : HTTP::Server::Context, plain value : String) : Nil
    context.response.content_type = Shepherd::Server::Mimes::TEXT_PLAIN
    context.response.print(value)
  end

  #simply assigning the status code
  def head(context : HTTP::Server::Context, status_code : Int32) : Nil
    context.response.status_code = status_code
  end

  def render(context : HTTP::Server::Context, json value, parser = nil)
    context.response.content_type = Shepherd::Server::Mimes::APPLICATION_JSON
    context.response.print value.to_json
  end

end
