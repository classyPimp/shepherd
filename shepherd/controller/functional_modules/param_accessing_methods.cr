module Shepherd::Controller::FunctionalModules::ParamAccessingMethods

  def params(context : HTTP::Server::Context) : Shepherd::Server::Request::Params
    Shepherd::Server::Request::Params.new(context.request)
  end

end
