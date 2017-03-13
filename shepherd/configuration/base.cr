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
    SUPPORTED_OPTIONS = [] of Symbol
    macro define_config_options(options)
      {% for name, option in options %}

        handle_option({{name}}, {{option.id}})

      {%end%}


       def self.set_option_by_sym(symbol_name : Symbol, value_to_set )
         case symbol_name
         {% for name in options.keys %}
         when :{{ name.id }}
           self.{{name.id}} = (value_to_set.as({{options[name][:type]}}))
         {% end %}
         else
           raise "no option"
         end
       end

    end

    macro handle_option(name, option)
      SUPPORTED_OPTIONS << :{{name.id}}
      @@{{name.id}} : {{option[:type].id}}?

      {%if option[:default]%}
        @@{{name.id}} = {{option[:default]}}
      {%end%}

      def self.{{name.id}} : {{option[:type].id}}?
        {% if option[:required] %}
          raise "required option was not set" if @@{{name.id}}.nil?
        {%end%}
        @@{{name.id}}
      end

      def self.{{name.id}}=(value : {{option[:type]}})
        @@{{name.id}} = value
      end

    end

    def self.set_options_by_hash(options)
      options.each do |key, value|
        self.set_option_by_sym(key, value)
      end
    end

end
