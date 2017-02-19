module Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing

  module Macros


    macro database_mapping(mapping_options)
      DATABASE_MAPPING = {{mapping_options}}
      {% column_names_and_their_options = mapping_options[:column_names] %}

      macro_set_table_name("{{mapping_options[:table_name].id}}")

      macro_set_primary_key({{column_names_and_their_options.id}})

      macro_set_field_properties_their_types({{column_names_and_their_options.id}})

      macro_set_string_db_field({{column_names_and_their_options.id}})

      macro_set_string_db_field_names_array_without_primary_key({{column_names_and_their_options.id}})

      macro_set_field_setter_by_column_name_procs({{column_names_and_their_options.id}})


      def assign_property_by(column_name : String, result_set : ::DB::ResultSet) : Nil
        if proc = @@field_setter_by_column_name_procs[column_name]?
          proc.call(self, result_set)
        else
          #move to next
          result_set.read
        end
      end


      macro_set_field_getter_by_column_name_procs({{column_names_and_their_options.id}})


      def get_property_by_name(column_name : String) : DB::Any
        @@field_getter_by_column_name_procs[column_name].call(self)
      end


    end

#
#
#
#
#
#
#

    macro macro_set_table_name(table_name)
      @@table_name : String
      @@table_name = "{{table_name.id}}"
    end


    macro macro_set_primary_key(column_names_and_their_options)

      {% for field_name, field_options in column_names_and_their_options %}
        {%if field_options[:primary_key]%}

          @@primary_key_name = "{{field_name.id}}"

        {% end %}
      {% end %}

    end


    macro macro_set_field_properties_their_types(column_names_and_their_options)

      {% for field_name, field_options in column_names_and_their_options %}

        property :{{field_name.id}}
        @{{field_name.id}} : {{field_options[:type]}}{{"?".id unless field_options[:nillable] == false}}

      {% end %}

    end


    macro macro_set_string_db_field(column_names_and_their_options)
      @@string_db_field_names_array = [

        {% size_flag = column_names_and_their_options.keys.size %}

        {% for field_name, field_options in column_names_and_their_options %}

          {% size_flag = size_flag - 1 %}

          "{{field_name.id}}"{{",".id unless size_flag == 0}}

        {% end %}
      ]
    end


    macro macro_set_string_db_field_names_array_without_primary_key(column_names_and_their_options)
    #FIXME: if only one field mapped will raise, e.g. only "id"
      {% array = [] of String %}

      {% for field_name, options in column_names_and_their_options %}
        {% array << "#{field_name.id}" unless options[:primary_key] %}
      {% end %}

      @@string_db_field_names_array_without_primary_key : Array(String)
      @@string_db_field_names_array_without_primary_key = {{array.id}}

    end


    macro macro_set_field_setter_by_column_name_procs(column_names_and_their_options)

      @@field_setter_by_column_name_procs = {
        {% size_flag =  column_names_and_their_options.keys.size %}
        {%  for field_name, field_options in column_names_and_their_options %}
          {% size_flag = size_flag - 1 %}
        "{{field_name.id}}":  Proc({{@type.id}}, ::DB::ResultSet, Nil).new do |model, result_set|
            if (value_to_assign_to_property = result_set.read)
              model.{{field_name.stringify.id}} = value_to_assign_to_property.as({{field_options[:type]}})
            end
          end{{",".id unless size_flag == 0}}
        {% end %}
      }

    end


    macro macro_set_field_getter_by_column_name_procs(column_names_and_their_options)
      @@field_getter_by_column_name_procs = {
        {% length =  column_names_and_their_options.keys.size %}
        {%  for field_name, field_options in column_names_and_their_options  %}
          {% length = length - 1 %}
        "{{field_name.id}}":  Proc( {{@type.id}}, DB::Any).new do |model|
              model.{{field_name.stringify.id}}
          end{{",".id unless length == 0}}
        {% end %}
      }
    end



  end

#
#
#
#
#
#
#


  module ClassMethods

    def table_name : String
      @@table_name
    end


    def string_db_field_names_array
      @@string_db_field_names_array
    end

    def string_db_field_names_array_without_primary_key
      @@string_db_field_names_array_without_primary_key
    end

    #Will iterate over result_set, and instantiate model for each row
    #with mapped fields assigned to corresponding properties
    def parse_db_result_set(result_set : DB::ResultSet) : Shepherd::Model::Collection

      collection = Shepherd::Model::Collection(self).new

      column_names = result_set.column_names

      result_set.each do
        collection << self.instantiate_model(result_set, column_names)
      end

      return collection

    end

    def instantiate_model(result_set : DB::ResultSet, column_names : Array)
      model = self.new

      column_names.each do |column_name|
        model.assign_property_by(column_name, result_set)
      end

      model
    end


  end


end
