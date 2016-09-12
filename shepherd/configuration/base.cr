class Shepherd::Configuration::Base


  #this macro is used for defining configuration options for given class
  #options is a Hash that follows this structure
  #{ configuration_option_name : Symbol  => {:type => TheType, :default (optional) => default value, required: Boolean } }
  # example usage
  # define_config_options(
  #   {
  #     host: {type: Int32, default: 3000},
  #     port: {type: String, default: "0.0.0.0"}
  #   }
  # )
  macro define_config_options(options)

   SUPPORTED_OPTIONS = [] of Symbol

   {% for config_name, config_options in options %}

     {% raise "no type given" if (config_options[:type] == nil) %}


     def set_{{config_name.id}}(value : {{ config_options[:type] }})

       @{{config_name.id}} = value

     end


     def get_{{ config_name.id }} {% if config_options[:type] %} : {{ config_options[:type] }} {% end %}

       {% if config_options[:required] && !config_options[:default] %}
           raise "config should be set" unless @{{config_name.id}}
       {% end %}

       @{{config_name.id}} {% if config_options[:default] %} || {{ config_options[:default] }} {% end %}

     end

     SUPPORTED_OPTIONS << :{{config_name}}

   {% end %}




   def set_option(symbol_name : Symbol, value_to_set )
     case symbol_name
     {% for name in options.keys %}
     when :{{ name.id }}
       set_{{name.id}}(value_to_set.as({{options[name][:type]}}))
     {% end %}
     else
       raise "no option"
     end
   end


 end


  def set_option
    raise "should be implemented"
  end

  def set_options(from hash)
    hash.each do |option_name, value|
      set_option(option_name, value)
    end
  end


end
