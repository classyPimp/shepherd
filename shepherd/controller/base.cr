require "./modules/**"

class Shepherd::Controller::Base

  @context : HTTP::Server::Context
  property :context


  def initialize(context : HTTP::Server::Context)
    @context = context
  end

  include Shepherd::Controller::Modules::ParamAccessingMethods

  include Shepherd::Controller::Modules::RenderingMethods


  macro has_functional_actions

    extend Shepherd::Controller::FunctionalModules::RenderingMethods
    extend Shepherd::Controller::FunctionalModules::ParamAccessingMethods

  end

end
