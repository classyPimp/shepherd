module Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing

  module Macros


    macro database_mapping(mapping_options)

      {% column_names_and_their_options = mapping_options[:column_names] %}

      macro_set_table_name("{{mapping_options[:table_name].id}}")

      macro_set_primary_key({{column_names_and_their_options.id}})

      macro_set_field_properties_their_types({{column_names_and_their_options.id}})

      macro_set_string_db_field({{column_names_and_their_options.id}})

      macro_set_string_db_field_names_array_without_primary_key({{column_names_and_their_options.id}})

      macro_set_database_field_names_and_their_indexes_string_keys({{column_names_and_their_options.id}})

      macro_set_database_field_names_and_their_indexes_symbol_keys({{column_names_and_their_options.id}})

      macro_generate_method_assign_db_field_property_by_its_index({{column_names_and_their_options.id}})

      macro_set_field_setter_by_column_name_procs({{column_names_and_their_options.id}})


      def assign_property_by_name(column_name : String, result_set : ::DB::ResultSet) : Nil
        @@field_setter_by_column_name_procs[column_name].call(self, result_set)
      end


      macro_set_field_getter_by_column_name_procs({{column_names_and_their_options.id}})


      def get_property_by_name(column_name : String) : DB::Any
        @@field_getter_by_column_name_procs[column_name].call(self)
      end

      macro_generate_method_get_db_field_property_by_its_index({{column_names_and_their_options.id}})


    end

#
#
#
#
#
#
#

    macro macro_set_table_name(table_name)
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
      {% array = [] of String %}

      {% for field_name, options in column_names_and_their_options %}
        {% array << "#{field_name.id}" unless options[:primary_key] %}
      {% end %}

      @@string_db_field_names_array_without_primary_key : Array(String)
      @@string_db_field_names_array_without_primary_key = {{array.id}}

    end

    macro macro_set_database_field_names_and_their_indexes_string_keys(column_names_and_their_options)
      @@database_field_names_and_their_indexes_string_keys = {
        {% x = 1 %}
        {% size_flag = column_names_and_their_options.keys.size %}
        {% for field_name, field_options in column_names_and_their_options %}

          {% size_flag = size_flag - 1 %}

          "{{field_name.id}}": {{x.id}}{{",".id unless size_flag == 0}}

          {% x = x + 1 %}

        {% end %}
      }
    end


    macro macro_set_database_field_names_and_their_indexes_symbol_keys(column_names_and_their_options)
      @@database_field_names_and_their_indexes_symbol_keys = {
        {% x = 0%}
        {% size_flag = column_names_and_their_options.keys.size %}
        {% for field_name, field_options in column_names_and_their_options%}
          {% x = x + 1 %}
          {% size_flag = size_flag - 1 %}

          {{field_name.id}}: {{x.id}}{{",".id unless size_flag == 0}}

        {% end %}
      }
    end

    macro macro_generate_method_assign_db_field_property_by_its_index(column_names_and_their_options)
      def assign_db_field_property_by_its_index(*, index : Int32, result_set : DB::ResultSet) : Nil
        {% x = 1 %}
        case index
            when 0
              #should move position to next if no mapping
              result_set.read
              return nil
          {%  for field_name, field_options in column_names_and_their_options  %}
            when {{x.id}}
              if (value_to_assign_to_property = result_set.read)
                @{{field_name.stringify.id}} = value_to_assign_to_property.as({{field_options[:type]}})
              end
            {% x = x + 1%}
          {% end %}
        end
      end
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


    macro macro_generate_method_get_db_field_property_by_its_index(column_names_and_their_options)
      def get_db_field_property_by_its_index(index : Int32) : ::DB::Any
        {% x = 1 %}
        case index
            when 0
              return nil
          {%  for field_name, field_options in column_names_and_their_options %}
            when {{x.id}}
              @{{field_name.stringify.id}}
            {% x = x + 1%}
          {% end %}
        end
      end
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
    def parse_db_result_set(result_set : DB::ResultSet) #need implement : ModelCollection
      #TODO: implement ModelCollection method
      collection = Shepherd::Model::Collection(self).new

      column_names = result_set.column_names

      indexes = calculate_indexes_for_db_fields_properties(column_names)

      result_set.each do
        collection << self.instantiate_model_with_indexes_mapped_to_db_result(indexes, result_set)
      end

      return collection

    end

    #dependent method of parse_db_result_set, will instantiate single model assiging fields to corresponding properties and pass it to calling method
    def instantiate_model_with_indexes_mapped_to_db_result(indexes : StaticArray, result_set : DB::ResultSet) : Shepherd::Model::Base

      model = self.new

      indexes.each do |index|
        model.assign_db_field_property_by_its_index(index: index, result_set: result_set)
      end

      return model

    end

    #eg @@database_field_names_and_their_indexes_string_keys_string_keys["id" => 1, "name" => 2]
    #result_set => column_names["id", "name"], row values [1, "foo"]
    #calculate_indexes_for_db_fields_properties(result_set) => [1,2]
    #result_set => column_names["name", "id"], row values ["foo", 1]
    ##calculate_indexes_for_db_fields_properties(result_set) => [2,1]
    #return value will be used to assign by index when parsing
    def calculate_indexes_for_db_fields_properties(column_names) : StaticArray

      size = column_names.size

      static_array_to_return = StaticArray[size, 0]

      column_names.each_with_index do |name, index|
        #if not mapped, will default to 0
        #properties are mapped on class starting from 1
        #defaulting to 0 is expected and used later in switch statement when assigning
        if index_for_column_name = @@database_field_names_and_their_indexes_string_keys[name]
          static_array_to_return[index] = index_for_column_name
        end

      end

      return static_array_to_return

    end



  end
end
