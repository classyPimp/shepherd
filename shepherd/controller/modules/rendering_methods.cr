module Shepherd::Controller::Modules::RenderingMethods


  #render plain like Rails does
  def render(plain value : String) : Nil
    @context.response.content_type = Shepherd::Server::Mimes::TEXT_PLAIN
    @context.response.print(value)
  end


  #simply assigning the status code
  def head(status_code : Int32) : Nil
    @context.response.status_code = status_code
  end



  def render(json value, parser = nil) : Nil
    @context.response.content_type = Shepherd::Server::Mimes::APPLICATION_JSON
    @context.response << value.to_json
  end


end
