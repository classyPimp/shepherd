class Shepherd::Model::Associations::GenerationMacros::BelongsTo::Polymorphic

  macro generate_for_join_builder(owner_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = owner_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key = config[:local_key] || "#{slave_class.stringify.split("::").downcase[-1]}_id" %}
    {% foreign_key = config[:foreign_key] || "id" %}
    {% alias_on_join_as = config[:alias_on_join_as] %}
    {% supported_types_ary = config[:supported_types].stringify.split('|').map(&.strip.id) %}
    {% slave_type_union = config[:supported_types]%}
    {% polymorphic_type_field = config[:polymorphic_type_field]%}

    {%for type in supported_types_ary%}
      def {{property_name.id}}(class_to_join : {{type}}.class, *, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = " AND #{{{owner_class}}.table_name}.{{polymorphic_type_field.id}} = '{{type.stringify.split("::")[-1].id}}' ")

        @join_statements << {
          join_type: @join_type,
          parent: {{owner_class}},
          class_to_join: {{type.id}},
          parent_column: {{local_key}},
          class_to_join_column: {{foreign_key}},
          alias_as: alias_as,
          extra_join_criteria: extra_join_criteria
        }

        {{ type.id }}::JoinBuilder.new(@join_type, @join_statements)

      end
    {%end%}
  end


  macro generate_for_eager_loader(owner_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = owner_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key_config = database_mapping[:column_names][config[:local_key]]%}
    {% local_key_type = local_key_config[:type] %}
    {% local_key = config[:local_key] || "#{slave_class.stringify.split("::").downcase[-1]}_id" %}
    {% foreign_key = config[:foreign_key] || "id" %}
    {% supported_types_ary = config[:supported_types].stringify.split('|').map(&.strip.id) %}
    {% slave_type_union = config[:supported_types]%}
    {% polymorphic_type_field = config[:polymorphic_type_field]%}

    def {{property_name.id}}

      repositories = {
        {% supported_types_ary_size_flag = supported_types_ary.size %}
        {% iterations_counter_flag = 0 %}
        {% for type in supported_types_ary%}
          {% iterations_counter_flag = iterations_counter_flag + 1 %}
          {{type.stringify.split("::")[-1]}}: {{type.id}}.repo {{",".id unless iterations_counter_flag == supported_types_ary_size_flag }}
        {% end %}
      }

      @resolver_proc = Proc(Shepherd::Model::Collection({{owner_class}}), Nil).new do |collection|

        mapper_by_local_key = {
          {% supported_types_ary_size_flag = supported_types_ary.size %}
          {% iterations_counter_flag = 0 %}
          {% for type in supported_types_ary%}
            {% iterations_counter_flag = iterations_counter_flag + 1 %}
            {{type.stringify.split("::")[-1]}}: Hash({{local_key_type}}, {{owner_class}}).new(initial_capacity: 20) {{",".id unless iterations_counter_flag == supported_types_ary_size_flag }}
          {% end %}
        }

        arrays_of_local_keys = {
          {% supported_types_ary_size_flag = supported_types_ary.size %}
          {% iterations_counter_flag = 0 %}
          {% for type in supported_types_ary%}
            {% iterations_counter_flag = iterations_counter_flag + 1 %}
            {{type.stringify.split("::")[-1]}}: Array({{local_key_type}}).new(20) {{",".id unless iterations_counter_flag == supported_types_ary_size_flag }}
          {% end %}
        }

        collection.each do |model|
          if model.{{local_key.id}}
            arrays_of_local_keys[model.{{polymorphic_type_field.id}}.not_nil!] << model.{{local_key.id}}.not_nil!
            mapper_by_local_key[model.{{polymorphic_type_field.id}}.not_nil!][model.{{local_key.id}}.not_nil!] = model
          end
        end

        arrays_of_local_keys.each do |name, array_of_local_keys|
          unless array_of_local_keys.empty?
            case name
            {% for type in supported_types_ary%}
            when {{type.stringify.split("::")[-1].id.symbolize}}
              child_collection = repositories[name].not_nil!.where( { {{foreign_key}}, :in, array_of_local_keys }).list
              child_collection.as(Shepherd::Model::Collection({{type.id}})).each do |child|
                mapper_by_local_key[name][child.{{foreign_key.id}}.not_nil!].{{property_name.id}} = child
              end
            {%end%}
            end
            #can't convince compiler that this will work:
            # child_collection = repositories[name].not_nil!.where( { {{foreign_key}}, :in, array_of_local_keys }).get
            #
            # child_collection.not_nil!.each do |child|
            #   mapper_by_local_key[name][child.{{foreign_key.id}}.not_nil!].{{property_name.id}} = child
            # end

          end
        end

      end

      repositories
    end

  end


  #
  # commentable: {
  #   type: :belongs_to,
  #   polymorphic: true,
  #   polymorphic_type_field: "commentable_type",
  #   supported_types: (Models::Post | Models::Discussion)
  #   local_key: "commentable_id"
  # }

  macro set(owner_class, property_name, config, aggregate_config, database_mapping)
    {% local_key = config[:local_key] || "#{property_name.id.stringify}_id" %}
    {% polymorphic_type_field = config[:polymorphic_type_field] || "#{property_name.id.stringify}_type"%}
    {% foreign_key = config[:foreign_key] || "id" %}
    {% supported_types_ary = config[:supported_types].stringify.split('|').map(&.strip.id) %}
    {% slave_type_union = config[:supported_types]%}


    {{@type}}.set_property({{property_name}}, {{slave_type_union}})
    {{@type}}.set_getter({{property_name}}, {{local_key}}, {{polymorphic_type_field}}, {{supported_types_ary}}, {{foreign_key}})
    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_type_union}})
    {{@type}}.set_getter_overload_to_yield_repo({{property_name}}, {{polymorphic_type_field}}, {{supported_types_ary}}, {{foreign_key}}, {{local_key}})
    {{@type}}.set_setter({{property_name}}, {{slave_type_union}})
  end


  macro set_property(property_name, slave_type_union)

    @{{property_name.id}} : {{slave_type_union}}?

  end


  macro set_getter(property_name, local_key, polymorphic_type_field, supported_types_ary, foreign_key)

    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key.id }}
          case @{{polymorphic_type_field.id}}
            {%for type in supported_types_ary%}
              when {{ type.stringify.split("::")[-1] }}
                {{type.id}}.repo.where(
                  {{type.id}}, { {{foreign_key}}, :eq, self.{{ local_key.id }} }
                ).limit(1).get
            {%end%}
          end
        else
          nil
        end
      )
    end

  end


  macro set_getter_overload_load_false(property_name, slave_type_union)

    def {{property_name.id}}(*, load : Bool) : ({{slave_type_union}})?
      @{{property_name.id}} ||= (
          nil
      )
    end

  end


  macro set_getter_overload_to_yield_repo(property_name, polymorphic_type_field, supported_types_ary, foreign_key, local_key)

    def {{property_name.id}}(yield_repo : Bool, &block)
      @{{property_name.id}} ||= (
        yield (
          case @{{polymorphic_type_field.id}}
            {%for type in supported_types_ary%}
              when {{ type.stringify.split("::")[-1] }}
                {{type.id}}.repo.where(
                  {{type.id}}, { {{foreign_key}}, :eq, self.{{ local_key.id }} }
                ).limit(1)
            {%end%}
          end
        )
      )
    end

  end


  macro set_setter(property_name, slave_type_union)

    def {{property_name.id}}=(value : {{slave_type_union.id}})
      @{{property_name.id}} = value
    end

  end

end
