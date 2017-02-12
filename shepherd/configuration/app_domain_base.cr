# configuration  concept:
# shepherd has the configuration domains e.g. server, security, db and etc.
# such classes inherit from Shepherd::Configuration::Base, and must define the available
# options and their types. each config option is accessible through get_#{config nanme}, and
# settable through set_#{configname}.
# so in user domain, if he wants to change the options (e.g. for diff env), he uses the classses that
# < AppDomainBase, which have macros to set options on shepherd configurations
# this way config is always typed, and incapsulated.
class Shepherd::Configuration::AppDomainBase

  def self.server(&block)
    yield Shepherd::Configuration::Server
  end

  def self.security(&block)

    yield Shepherd::Configuration::Security

  end

  def self.set_config : Nil

  end

  def set_config
    self.class.set_config
  end

end
