class Shepherd::Configuration::Database < Shepherd::Configuration::Base

  INSTANCE = new

  define_config_options({

    connection_pool_capacity: { type: Int32, default: 25, required: true},
    connection_pool_timeout: {type: Float64, default: 0.01, required: true},
    connection_address: {default: "postgresql://postgres:postgres@localhost/foo", type: String, required: true}

  })


end
