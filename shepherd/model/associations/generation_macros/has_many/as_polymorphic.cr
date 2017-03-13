class Shepherd::Model::Associations::GenerationMacros::HasMany::AsPolymorphic


  macro generate_for_join_builder(owner_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = owner_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key = config[:local_key] %}
    {% foreign_key = config[:foreign_key] %}
    {% alias_on_join_as = config[:alias_on_join_as] %}
    {% foreign_polymorphic_type_field = config[:foreign_polymorphic_type_field] %}
    {% owner_class_name_for_type_field = owner_class.stringify.split("::")[-1]%}

    def {{property_name.id}}(*, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = " AND #{{{slave_class}}.table_name}.{{foreign_polymorphic_type_field.id}} = '{{owner_class_name_for_type_field.id}}' ")

      @join_statements << {
        join_type: @join_type,
        parent: {{owner_class}},
        class_to_join: {{slave_class}},
        parent_column: {{local_key}},
        class_to_join_column: {{foreign_key}},
        alias_as: alias_as,
        extra_join_criteria: extra_join_criteria
      }

      {{ slave_class }}::JoinBuilder.new(@join_type, @join_statements)

    end

  end


  macro generate_for_eager_loader(owner_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = owner_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key_config = database_mapping[:column_names][config[:local_key]]%}
    {% local_key_type = local_key_config[:type] %}
    {% local_key = config[:local_key] %}
    {% foreign_key = config[:foreign_key] %}
    {% owner_class_name_for_type_field = owner_class.stringify.split("::")[-1]%}
    {% foreign_polymorphic_type_field = config[:foreign_polymorphic_type_field] %}

    def {{property_name.id}}

      repo = {{slave_class}}.repo

      @resolver_proc = Proc(Shepherd::Model::Collection({{owner_class}}), Nil).new do |collection|

        mapper_by_local_key = {} of {{local_key_type}} => {{owner_class}}
        array_of_local_keys = [] of {{local_key_type}}

        collection.each do |model|
          if model.{{local_key.id}}
            array_of_local_keys << model.{{local_key.id}}.not_nil!
            mapper_by_local_key[model.{{local_key.id}}.not_nil!] = model
          end
        end

        unless array_of_local_keys.empty?
          child_collection = repo.not_nil!.where(
            {{slave_class}}.table_name, { {{foreign_key}}, :in, array_of_local_keys }
          ).where(
            {{slave_class}}.table_name, { {{foreign_polymorphic_type_field}}, :eq, {{ owner_class_name_for_type_field }} }
          ).list

          child_collection.each do |child|
            mapper_by_local_key[child.{{foreign_key.id}}].{{property_name.id}}(load: false) << child
          end
        end

      end

      repo
    end

  end



  #has many plain; direct relation
  # comments: {
  #   type: :has_many,
  #   class_name: Models::Comment, #TODO: can be infered
  #   local_key: "id", #TODO: can be infered
  #   foreign_key: "commentable_id", #TODO: can be infered
  #   foreign_polymorphic_type_field: "commentable_type",
  # }

  macro set(owner_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = owner_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key = config[:local_key] || "id" %}
    {% foreign_polymorphic_type_field = config[:foreign_polymorphic_type_field] %}
    {% foreign_key = config[:foreign_key] || "#{foreign_polymorphic_type_field[0..-5]}_id" %} #-5_type
    {% owner_class_name_for_type_field = owner_class.stringify.split("::")[-1]%}
    {% alias_on_join_as = config[:alias_on_join_as] %}

    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{local_key}}, {{foreign_key}}, {{foreign_polymorphic_type_field}}, {{owner_class_name_for_type_field}})

    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_class}})

    {{@type}}.set_getter_overload_to_yield_repo({{property_name}}, {{slave_class}}, {{foreign_key}}, {{local_key}}, {{owner_class_name_for_type_field}}, {{foreign_polymorphic_type_field}})

    {{@type}}.set_setter({{property_name}}, {{slave_class}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : Shepherd::Model::Collection({{slave_class}})?

  end


  macro set_getter(property_name, slave_class, local_key, foreign_key, foreign_polymorphic_type_field,owner_class_name_for_type_field)
    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key.id }}
          {{slave_class}}.repo.where(
            {{slave_class}}.table_name, { "{{foreign_key.id}}", :eq, self.{{ local_key.id }} },
                                        { {{foreign_polymorphic_type_field}}, :eq, {{ owner_class_name_for_type_field }} }
          ).list
        else
          Shepherd::Model::Collection({{slave_class}}).new
        end
      ).as(Shepherd::Model::Collection({{slave_class}}))
    end

  end


  macro set_getter_overload_load_false(property_name, slave_class)

    def {{property_name.id}}(*, load : Bool)
      @{{property_name.id}} ||= (
          Shepherd::Model::Collection({{slave_class}}).new
      ).as(Shepherd::Model::Collection({{slave_class}}))
    end

  end


  macro set_getter_overload_to_yield_repo(property_name, slave_class, foreign_key, local_key, owner_class_name_for_type_field, foreign_polymorphic_type_field)

    def {{property_name.id}}(yield_repo : Bool, &block)
      @{{property_name.id}} ||= (
        yield ({{slave_class}}.repo.where(
          {{slave_class}}.table_name, { {{foreign_key}}, :eq, self.{{ local_key.id }} },
                                      { {{foreign_polymorphic_type_field}}, :eq, {{ owner_class_name_for_type_field }} }
        ))
      )
    end

  end


  macro set_setter(property_name, slave_class)

    def {{property_name.id}}=(value : Shepherd::Model::Collection({{slave_class.id}}))
      @{{property_name.id}} = value
    end

  end
  #END HASMANY


end
