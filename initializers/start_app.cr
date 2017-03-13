#entry point for application
#calls the main initialier which is responsible for configuration setting, and
#starting the server. Call aceesses the singleton.
# env = Shepherd::Configuration::CliParser.instance.read_env
# case env
# when "development"
#   Shepherd::Configuration::General.env = ::Config::Env::Development.new
# when "test"
#   Shepherd::Configuration::General.env = ::Config::Env::Test.new
# end

Shepherd::Initializers::Main.start_application
