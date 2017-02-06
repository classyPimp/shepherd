module Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing

  module Macros

    #this macro is central for mapping properties to database fields
    #it will set the config like @@database_field_names_and_their_indexes_string_keys
    #and define a method assign_db_field_property_by_its_index which is used when parsing result
    #the @database_field_names_and_their_indexes_string_keys will contain "abstract" index, used later when result is fetched
    ##calculate_indexes_for_db_fields_properties will build array of these indexes which can be iterated to populate
    #eg @@database_field_names_and_their_indexes_string_keys["id" => 1, "name" => 2]
    #result_set => column_names["id", "name"], row values [1, "foo"]
    #calculate_indexes_for_db_fields_properties(result_set) => [1,2]
    #result_set => column_names["name", "id"], row values ["foo", 1]
    ##calculate_indexes_for_db_fields_properties(result_set) => [2,1]
    #TODO: think of maybe can be optimized by storing assigning proc in static array, and later accessed by offset
    #TODO: properties should be nillable by default, and explisitly set if otherwise
    macro database_mapping(mapping_options)

      #this part will result in following: example
      #database_mapping {
      #   table_name: "users"
      #   column_names: {
      #     {"id" => {type: String, nillable: true}}
      #   }
      # }

      #property :id
      #@id : String?
      #@@database_field_names_and_their_indexes_string_keys => {"id" => 1}
      #@@table_name = "users"

      @@table_name = "{{mapping_options[:table_name].id}}"

      #sets propety and it's type
      {% x = 1 %}
      {% for field_name, field_options in mapping_options[:column_names] %}

        property :{{field_name.id}}
        @{{field_name.id}} : {{field_options[:type]}}{{"?".id unless field_options[:nillable] == false}}
        {%if field_options[:primary_key]%}
          @@primary_key_name = "{{field_name.id}}"
        {% end %}
      {% x = x + 1 %}
      {% end %}



      @@string_db_field_names_array = [

        {% size_flag = mapping_options[:column_names].keys.size %}
        {% for field_name, field_options in mapping_options[:column_names] %}

          {% size_flag = size_flag - 1 %}

          "{{field_name.id}}"{{",".id unless size_flag == 0}}

        {% end %}
      ]

      @@string_db_field_names_array_without_primary_key : Array(String)
      @@string_db_field_names_array_without_primary_key = @@string_db_field_names_array.reject do |name|
        name == @@primary_key_name
      end


      @@database_field_names_and_their_indexes_string_keys = {
        {% x = 1 %}
        {% size_flag = mapping_options[:column_names].keys.size %}
        {% for field_name, field_options in mapping_options[:column_names] %}

          {% size_flag = size_flag - 1 %}

          "{{field_name.id}}": {{x.id}}{{",".id unless size_flag == 0}}

          {% x = x + 1 %}

        {% end %}
      }


      @@database_field_names_and_their_indexes_symbol_keys = {
        {% x = 1 %}
        {% size_flag = mapping_options[:column_names].keys.size %}
        {% for field_name, field_options in mapping_options[:column_names] %}

          {% size_flag = size_flag - 1 %}

          {{field_name.id}}: {{x.id}}{{",".id unless size_flag == 0}}

          {% x = x + 1 %}

        {% end %}
      }

      #this part will result in following: example
      #database_mapping {"id" => {type: String, nillable: true}}
      # def assign_db_field_property_by_its_index(index : Int32, result_set : DB::ResultSet) : Nil
      #   case index
      #     #0 will be in index by default if no value under column_name is mapped to model
      #     when 0
      #       return nil
      #     when 1
      #       if (value_to_assign_to_property = result_set.read)
      #         @id = value_to_assign_to_property.as(String)
      #       end
      #   end
      # end
      def assign_db_field_property_by_its_index(*, index : Int32, result_set : DB::ResultSet) : Nil
        {% x = 1 %}
        case index
            when 0
              #should move position to next if no mapping
              result_set.read
              return nil
          {%  for field_name, field_options in mapping_options[:column_names]  %}
            when {{x.id}}
              if (value_to_assign_to_property = result_set.read)
                @{{field_name.stringify.id}} = value_to_assign_to_property.as({{field_options[:type]}})
              end
            {% x = x + 1%}
          {% end %}
        end
      end



      @@field_setter_by_column_name_procs = {
        {% size_flag =  mapping_options[:column_names].keys.size %}
        {%  for field_name, field_options in mapping_options[:column_names]  %}
          {% size_flag = size_flag - 1 %}
        "{{field_name.id}}":  Proc({{@type.id}}, ::DB::ResultSet, Nil).new do |model, result_set|
            if (value_to_assign_to_property = result_set.read)
              model.{{field_name.stringify.id}} = value_to_assign_to_property.as({{field_options[:type]}})
            end
          end{{",".id unless size_flag == 0}}
        {% end %}
      }


      def assign_property_by_name(column_name : String, result_set : ::DB::ResultSet) : Nil
        @@field_setter_by_column_name_procs[column_name].call(self, result_set)
      end



      @@field_getter_by_column_name_procs = {
        {% length =  mapping_options[:column_names].keys.size %}
        {%  for field_name, field_options in mapping_options[:column_names]  %}
          {% length = length - 1 %}
        "{{field_name.id}}":  Proc( {{@type.id}}, DB::Any).new do |model|
              model.{{field_name.stringify.id}}
          end{{",".id unless length == 0}}
        {% end %}
      }

      def get_property_by_name(column_name : String) : DB::Any
        @@field_getter_by_column_name_procs[column_name].call(self)
      end


      #get_by_index
      def get_db_field_property_by_its_index(index : Int32) : ::DB::Any
        {% x = 1 %}
        case index
            when 0
              return nil
          {%  for field_name, field_options in mapping_options[:column_names]  %}
            when {{x.id}}
              @{{field_name.stringify.id}}
            {% x = x + 1%}
          {% end %}
        end
      end

      # #get_by_its_name
      # def get_db_field_property_by_its_field_name(field_name : String) : ::DB::Any
      #   {% x = 1 %}
      #   case field_name
      #   when 0
      #     return nil
      #   {%  for field_name, field_options in mapping_options[:column_names]  %}
      #   when "{{field_name.id}}"
      #         @{{field_name.id}}
      #       {% x = x + 1%}
      #   {% end %}
      #   end
      # end

    end

  end

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
