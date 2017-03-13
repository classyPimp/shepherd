class Shepherd::Model::Associations::GenerationMacros::HasMany::Plain


  macro generate_for_join_builder(master_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key = config[:local_key] %}
    {% foreign_key = config[:foreign_key] %}
    {% alias_on_join_as = config[:alias_on_join_as] %}

    def {{property_name.id}}(*, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = nil)

      @join_statements << {
        join_type: @join_type,
        parent: {{master_class}},
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
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key_config = database_mapping[:column_names][config[:local_key]]%}
    {% local_key_type = local_key_config[:type] %}
    {% local_key = config[:local_key] %}
    {% foreign_key = config[:foreign_key] %}

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
          child_collection = repo.not_nil!.where({{slave_class}}.table_name, { {{foreign_key}}, :in, array_of_local_keys }).list

          child_collection.each do |child|
            mapper_by_local_key[child.{{foreign_key.id}}].{{property_name.id}}(load: false) << child
          end
        end

      end

      repo
    end

  end



  #has many plain; direct relation
  # posts: {
  #   type: :has_many,
  #   class_name: Models::Post, #TODO: can be infered
  #   local_key: "id", #TODO: can be infered
  #   foreign_key: "user_id" #TODO: can be infered
  # }

  macro set(master_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% local_key = config[:local_key] || "id" %}
    {% foreign_key = config[:foreign_key] || "#{master_class.stringify.split("::").downcase}_id" %}


    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{local_key}}, {{foreign_key}})

    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_class}})

    {{@type}}.set_getter_overload_to_yield_repo({{property_name}}, {{slave_class}}, {{foreign_key}}, {{local_key}})

    {{@type}}.set_setter({{property_name}}, {{slave_class}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : Shepherd::Model::Collection({{slave_class}})?

  end


  macro set_getter(property_name, slave_class, local_key, foreign_key)
    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key.id }}
          {{slave_class}}.repo.where(
          {{slave_class}}.table_name, { "{{foreign_key.id}}", :eq, self.{{ local_key.id }} }
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


  macro set_getter_overload_to_yield_repo(property_name, slave_class, foreign_key, local_key)

    def {{property_name.id}}(yield_repo : Bool, &block)
      @{{property_name.id}} ||= (
        yield ({{slave_class}}.repo.where(
          {{slave_class}}.table_name, { {{foreign_key}}, :eq, self.{{ local_key.id }} }
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
