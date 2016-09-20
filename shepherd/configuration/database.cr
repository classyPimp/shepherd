class Shepherd::Configuration::Database < Shepherd::Configuration::Base

  INSTANCE = new

  define_config_options({

    connection_pool_capacity: { type: Int32, default: 25, required: true},
    connection_pool_timeout: {type: Float32, default: 0.01, required: true}

  })

end
