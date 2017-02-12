class Shepherd::Configuration::Services::CliToConfigTransmitter



  INSTANCE = new


  def self.transmit_cli_options(options) : Nil
    INSTANCE.transmit_to_top_level_config(options)
  end


  #responsible to setting config options on appropriate configuration class
  #reson behind is that CliParser is responsible fog parsing only and should not
  #know the config classes and shouldn't set on them
  #instead this class should contain such logic and be responsible for it and know
  #which options go to which exact config classes
  def transmit_to_top_level_config(options) : Nil

    options_to_pass = options.reject do |k,v|
      unless Shepherd::Configuration::Server::SUPPORTED_OPTIONS.includes?(k)
        true
      end
    end

    Shepherd::Configuration::Server.set_options_by_hash(options_to_pass)

  end



end
