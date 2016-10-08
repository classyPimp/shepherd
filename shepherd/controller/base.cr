require "./modules/**"

class Shepherd::Controller::Base



  #EXPERIMENT

  ACTIONS_ALREADY_DEFINED = [] of Symbol
  BEFORE_FILTERS_ALREADY_DEFINED = [] of Symbol



  macro inherited
    ACTIONS_ALREADY_DEFINED = [] of Symbol
    BEFORE_FILTERS_ALREADY_DEFINED = [] of Symbol
  end



  macro action(name, &block)

    {% ACTIONS_ALREADY_DEFINED << name %}

    {% unless BEFORE_FILTERS_ALREADY_DEFINED.includes?(name) %}

      def before_{{name.id}} : Bool
        true
      end

    {%end%}

    def {{name.id}}
      if before_action
        if before_{{name.id}}
          block.body
        end
      end
    end


  end


  macro before(name, &block)

    {% BEFORE_FILTERS_ALREADY_DEFINED << name %}

    def before_{{name.id}} : Bool
      {{block.body}}
    end

  end


  #EXPERIMENT END






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
