require "option_parser"

#class resonsible for parsing CLI options, and acts as storage for them.
#stored options are not accessed directly, Shepherd::Configuration::Services::CliToConfigTransmitter responsible
#for assigning stored options to appropriate configuration classes.
class Shepherd::Configuration::CliParser


  INSTANCE = new

  #singleton accessor
  def self.instance
    INSTANCE
  end

  #defaulty instantiated with blank array
  @options_passed_from_cli = {} of Symbol => ( Int32 | String )


  getter :options_passed_from_cli


  def initialize
    parse_cli_options
  end

  #parses and stores the passed CLI options
  def parse_cli_options : Nil

    OptionParser.parse! do |cli_options|

      cli_options.on("-b HOST", "Host to bind (defaults to 0.0.0.0)") do |host|
        @options_passed_from_cli[:host] = host
      end

      cli_options.on("-p PORT", "Port (defaults to 3000)") do |port|
        @options_passed_from_cli[:port] = port.to_i
      end

    end

  end





end
