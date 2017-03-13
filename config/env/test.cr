class Config::Env::Test < Shepherd::Configuration::AppDomainBase



  def self.set_config

    self.security do |config|

      config.secret_key = "asdasdasdasdasd"

    end

  end


end
