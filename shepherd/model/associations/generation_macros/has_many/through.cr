class Shepherd::Model::GenerationMacros::HasMany::Through


  macro generate_for_join_builder(master_class, property_name, config, aggregate_config, database_mapping)
    #{% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    #{% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    #{% through_class = config[:through_class] %}
    #{% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    #{% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}
    {% through = config[:through] %}

    def {{property_name.id}}(*, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = nil)

      self.inner_join(&.{{through.id}}.inner_join(&.{{that_joined_through.id}}(alias_as: alias_as, extra_join_criteria: extra_join_criteria)))

    end

  end


  macro generate_for_eager_loader(owner_class, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% through = config[:through]%}
    {% local_key_for_through_options = database_mapping[:column_names][options[:local_key]]%}
    {% local_key_type = local_key[:type] %}
    {% local_key = config[:local_key] %}
    {% foreign_key = config[:foreign_key] %}
    {% through_ass_options = aggregate_config[options[:through]] %}
    {% local_key_options = DATABASE_MAPPING[:column_names][through_ass_options[:local_key]]%}


    def {{property_name.id}}

      repository = {{slave_class}}.repository.init_where

      @resolver_proc = Proc(Shepherd::Model::Collection({{owner_class}}), Nil).new do |collection|
        #TODO: ideally should read types of fields out of results of db_mapping macro
        mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
        array_of_local_keys = [] of {{local_key_options[:type]}}

        collection.each do |model|
          if model.{{through_ass_options[:local_key].id}}
            array_of_local_keys << model.{{through_ass_options[:local_key].id}}.not_nil!
            mapper_by_local_key[model.{{through_ass_options[:local_key].id}}.not_nil!] = model
          end
        end

        unless array_of_local_keys.empty?
          child_collection = repository.not_nil!.inner_join(&.{{options[:this_joined_through].id}})
            .where({{through_ass_options[:class_name]}}, { {{through_ass_options[:foreign_key]}}, :in, array_of_local_keys })
            .execute

          child_collection.each do |child|
            mapper_by_local_key[child.{{through_ass_options[:foreign_key].id}}].{{property_name.id}}(load: false) << child
          end
        end

      end


      repository
    end

  end



  # users: {type: :has_many, through: :subscriptions, this_joined_through: subscriptions, that_joined_through: subscribers}
  macro set_has_many(master_class, property_name, config, aggregate_config)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    {% through_class = config[:through_class] %}
    {% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    {% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}

    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{through_class}}, {{this_joined_through}}, {{that_joined_through}}, {{local_key_for_through}}, {{foreign_key_for_through}})

    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_class}})

    {{@type}}.set_getter_overload_to_yield_repository({{property_name}}, {{slave_class}}, {{foreign_key}}, {{local_key}})

    {{@type}}.macro_set_setter({{property_name}}, {{slave_class}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : Shepherd::Model::Collection({{slave_class}})?

  end


  macro set_getter(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through)

    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key_for_through.id }}
          {{slave_class}}.repository
            .inner_join(&.{{this_joined_through.id}}
            .where({{through_class}}, { {{foreign_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
            .execute
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


  macro set_getter_overload_to_yield_repository(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through)

    def {{property_name.id}}(yield_repository : Bool, &block)
      @{{property_name.id}} ||= (
        yield (
          {{slave_class}}.repository
            .inner_join(&.{{this_joined_through.id}}
            .where({{through_class}}, { {{foreign_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
        )
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
