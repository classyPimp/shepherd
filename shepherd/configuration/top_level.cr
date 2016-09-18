class Shepherd::Configuration::General < Shepherd::Configuration::Base

  INSTANCE = new

  protected def self.instance
    INSTANCE
  end

  define_config_options({

    env: { type: String, default: "development", required: true}

  })

end
