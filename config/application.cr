class Config::Application < Shepherd::Configuration::Base

  INSTANCE = new

  def self.instance
    INSTANCE
  end

  define_config_options({

    project_root: { type: String, default: "#{Dir.current}/../", required: true}

  })


end
