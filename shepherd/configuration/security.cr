class Shepherd::Configuration::Security < Shepherd::Configuration::Base

  INSTANCE  = new

  define_config_options({

    secret_key: {type: String, default: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", required: true}

  })

end
