#entry point for application
#calls the main initialier which is responsible for configuration setting, and
#starting the server. Call aceesses the singleton.
Shepherd::Initializers::Main.start_application
