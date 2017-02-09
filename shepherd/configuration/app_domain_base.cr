# configuration  concept:
# shepherd has the configuration domains e.g. server, security, db and etc.
# such classes inherit from Shepherd::Configuration::Base, and must define the available
# options and their types. each config option is accessible through get_#{config nanme}, and
# settable through set_#{configname}.
# so in user domain, if he wants to change the options (e.g. for diff env), he uses the classses that
# < AppDomainBase, which have macros to set options on shepherd configurations
# this way config is always typed, and incapsulated.
class Shepherd::Configuration::AppDomainBase

  macro inherited
    INSTANCE = new
  end


  def self.instance
    INSTANCE
  end


  @current_config_class = ""

  macro server(&block)

    @current_config_class = "Shepherd::Configuration::Server::INSTANCE"

    {{block.body}}

  end

  macro security(&block)

    @current_config_class = "Shepherd::Configuration::Security::INSTANCE"

    {{block.body}}

  end

  macro constantize_config_class(name)
    {{ name.id }}
  end

  macro set(pair)
    {% for key, val in pair  %}
      constantize_config_class(@current_config_class).set_{{ key.id }}({{pair}})
    {% end %}
  end

  def self.set_config : Nil

  end

end
