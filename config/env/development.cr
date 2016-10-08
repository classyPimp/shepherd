class Config::Env::Development < Shepherd::Configuration::AppDomainBase


  def set_config

    # server do
    #
    #
    #
    # end


    security do

      set secret_key: "asdasdasdasdasd"

    end

  end


end
