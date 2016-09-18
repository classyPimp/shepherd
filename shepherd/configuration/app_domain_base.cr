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
