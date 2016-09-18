class Shepherd::Configuration::Server < Shepherd::Configuration::Base

  INSTANCE = new

  protected def self.instance
    INSTANCE
  end

  define_config_options({

    port: { type: Int32, default: 3000, required: true},

    host: { type: String, default: "0.0.0.0", required: true }

  })

end
