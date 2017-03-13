class Shepherd::Configuration::General < Shepherd::Configuration::Base

  INSTANCE = new

  protected def self.instance
    INSTANCE
  end

  define_config_options({

    env: { type: Shepherd::Configuration::AppDomainBase, default: Config::Env::Development.new, required: true}

  })

end
