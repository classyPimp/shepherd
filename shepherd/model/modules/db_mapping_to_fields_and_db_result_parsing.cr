module Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing

  module Macros

    #will set properties, their proc setters etc.
    macro database_mapping(mapping_options)
      DATABASE_MAPPING = {{mapping_options}}
      {% column_names_and_their_options = mapping_options[:column_names] %}

      macro_set_table_name("{{mapping_options[:table_name].id}}")

      macro_set_primary_key({{column_names_and_their_options.id}})

      macro_set_field_properties_their_types({{column_names_and_their_options.id}})

      macro_set_string_db_field({{column_names_and_their_options.id}})

      macro_set_string_db_field_names_array_without_primary_key({{column_names_and_their_options.id}})

      macro_set_field_setter_by_column_name_procs({{column_names_and_their_options.id}})

      # assignes propery that is generated via database_mapping
      # by it\'s string name representation, and result set with pointer to corresponding value
      #refer to #set_field_setter_by_column_name_procs for detailed info
      def assign_property_by(column_name : String, result_set : ::DB::ResultSet) : Nil
        # if columname was mapped to model,
        # calls the assigned proc
        if proc = @@field_setter_by_column_name_procs[column_name]?
          proc.call(self, result_set)
        else
          #if column name was not mapped to value
          #move to next, read voidly, just moves pointer offset to next value
          result_set.read
        end
      end


      macro_set_field_getter_by_column_name_procs({{column_names_and_their_options.id}})

      #returns propery value by passing it's stingified name
      def get_property_by_name(column_name : String) : DB::Any
        @@field_getter_by_column_name_procs[column_name].call(self)
      end


    end

    #sets class var holding table name
    macro macro_set_table_name(table_name)
      @@table_name : String
      @@table_name = "{{table_name.id}}"
    end

    #sets class var holding primary_key name
    macro macro_set_primary_key(column_names_and_their_options)

      {% for field_name, field_options in column_names_and_their_options %}
        {%if field_options[:primary_key]%}

          @@primary_key_name = "{{field_name.id}}"

        {% end %}
      {% end %}

    end

    #sets properties typed accordingly
    macro macro_set_field_properties_their_types(column_names_and_their_options)

      {% for field_name, field_options in column_names_and_their_options %}

        property :{{field_name.id}}
        @{{field_name.id}} : {{field_options[:type]}}{{"?".id unless field_options[:nillable] == false}}

      {% end %}

    end

    #sets to class var an array : String of db field names
    macro macro_set_string_db_field(column_names_and_their_options)
      @@string_db_field_names_array = [

        {% size_flag = column_names_and_their_options.keys.size %}

        {% for field_name, field_options in column_names_and_their_options %}

          {% size_flag = size_flag - 1 %}

          "{{field_name.id}}"{{",".id unless size_flag == 0}}

        {% end %}
      ]
    end

    #sets to class var an array : String of db field names
    #required for example in repository#create, to not save the primary key
    macro macro_set_string_db_field_names_array_without_primary_key(column_names_and_their_options)
    #FIXME: if only one field mapped will raise, e.g. only "id"
      {% array = [] of String %}

      {% for field_name, options in column_names_and_their_options %}
        {% array << "#{field_name.id}" unless options[:primary_key] %}
      {% end %}

      @@string_db_field_names_array_without_primary_key : Array(String)
      @@string_db_field_names_array_without_primary_key = {{array.id}}

    end

    # #main db parsing method,
    # sets a named tuple which holds stringified db field name (property) as keys
    # and procs that basically set them as values
    # like simplified: {"user_name": ->(user_name){model.user_name = user_name}}
    # and works like this:
    # db is queried
    # result set is returned
    # result set holds column names, and repeating sets of values
    #  `.instantiate_model` passes column name along with result set with pointer to corresponding value
    # if column name was mapped it will call the assigning proc passing result set
    # in that proc result set will be read for one value and assigned to property
    # moving its position to next pair of col name and value and so one
    # if column name was not mapped, result is simply voidly read (pointer moved to next offset).
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

    #simplified: {"user_id": ->{ return model.user_id }}
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
    #required in repository methods
    def table_name : String
      @@table_name
    end

    #required in repository methods
    def string_db_field_names_array
      @@string_db_field_names_array
    end
    #accessor, required for e.g. in repository methods
    def string_db_field_names_array_without_primary_key
      @@string_db_field_names_array_without_primary_key
    end

    #Will iterate over result_set, and instantiate model for each row
    #with mapped fields assigned to corresponding properties
    #refer to `#set_field_setter_by_column_name_procs` macro
    def parse_db_result_set(result_set : DB::ResultSet) : Shepherd::Model::Collection

      collection = Shepherd::Model::Collection(self).new

      column_names = result_set.column_names

      result_set.each do
        collection << self.instantiate_model(result_set, column_names)
      end

      return collection

    end

    #refer to `#set_field_setter_by_column_name_procs` macro for more info
    def instantiate_model(result_set : DB::ResultSet, column_names : Array)
      model = self.new

      column_names.each do |column_name|
        model.assign_property_by(column_name, result_set)
      end

      model
    end


  end


end
