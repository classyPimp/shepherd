class Shepherd::Model::Associations::GenerationMacros::HasOne::Through


  macro generate_for_join_builder(master_class, property_name, config, aggregate_config, database_mapping)
    #{% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    #{% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    #{% through_class = config[:through_class] %}
    #{% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    #{% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}
    {% through = config[:through] %}
    {% alias_on_join_as = config[:alias_on_join_as] %}

    def {{property_name.id}}(*, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = nil)

      self.inner_join(&.{{through.id}}.inner_join(&.{{that_joined_through.id}}(alias_as: alias_as, extra_join_criteria: extra_join_criteria)))

    end

  end


  macro generate_for_eager_loader(owner_class, property_name, config, aggregate_config, database_mapping)

    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}

    {% through_relation_name = config[:through]%}
    {% options_for_through_relation = aggregate_config[through_relation_name] %}

    {% local_key_for_through = options_for_through_relation[:local_key] %}
    {% local_key_for_through_config = database_mapping[:column_names][local_key_for_through] %}

    {% local_key_for_through_type = local_key_for_through_config[:type] %}
    {% foreign_key_for_through = options_for_through_relation[:foreign_key] %}
    {% through_relation_class_name = options_for_through_relation[:class_name] %}

    {% this_joined_through = config[:this_joined_through] %}

    def {{property_name.id}}

      repo = {{slave_class}}.repo

      @resolver_proc = Proc(Shepherd::Model::Collection({{owner_class}}), Nil).new do |collection|
        #TODO: ideally should read types of fields out of results of db_mapping macro
        mapper_by_local_key = {} of {{local_key_for_through_type}} => {{owner_class}}
        array_of_local_keys = [] of {{local_key_for_through_type}}

        collection.each do |model|
          if model.{{local_key_for_through.id}}
            array_of_local_keys << model.{{local_key_for_through.id}}.not_nil!
            mapper_by_local_key[model.{{local_key_for_through.id}}.not_nil!] = model
          end
        end

        unless array_of_local_keys.empty?
          child_collection = repo.not_nil!.inner_join(&.{{this_joined_through.id}})
            .where(
              {{through_relation_class_name}},
              { {{foreign_key_for_through}}, :in, array_of_local_keys }
            ).list

          child_collection.each do |child|
            mapper_by_local_key[child.{{local_key_for_through.id}}].{{property_name.id}} = child
          end
        end

      end


      repo
    end

  end


  #Has one through relation:
  # association to through can be plain has_one, plain has_one, or plain belongs_to
  # relatives: {
  #   type: :has_one,
  #   class_name: Models::Person #TODO: can be inferred
  #   through: :family,
  #   this_joined_through: family, # person joins family #this visible #TODO: can be infered
  #   that_joined_through: family_members, #family joins family_members #person visible #TODO: can be infered
  # }
  macro set(master_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    {% through_class = config[:through_class] %}
    {% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    {% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}

    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{through_class}}, {{this_joined_through}}, {{that_joined_through}}, {{local_key_for_through}}, {{foreign_key_for_through}})

    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_class}})

    {{@type}}.set_getter_overload_to_yield_repo({{property_name}}, {{slave_class}}, {{through_class}}, {{this_joined_through}}, {{that_joined_through}}, {{local_key_for_through}}, {{foreign_key_for_through}})

    {{@type}}.set_setter({{property_name}}, {{slave_class}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : {{slave_class}}?

  end


  macro set_getter(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through)

    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key_for_through.id }}
          {{slave_class}}.repo
            .inner_join(&.{{this_joined_through.id}})
            .where({{through_class}}, { {{local_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
            .limit(1)
            .get
        else
          nil
        end
      )
    end

  end


  macro set_getter_overload_load_false(property_name, slave_class)

    def {{property_name.id}}(*, load : Bool)
      @{{property_name.id}} ||= (
          nil
      )
    end

  end


  macro set_getter_overload_to_yield_repo(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through)

    def {{property_name.id}}(yield_repo : Bool, &block)
      @{{property_name.id}} ||= (
        yield (
          {{slave_class}}.repo
            .inner_join(&.{{this_joined_through.id}})
            .where({{through_class}}, { {{local_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
            .limit(1)
        )
      )
    end

  end


  macro set_setter(property_name, slave_class)

    def {{property_name.id}}=(value : {{slave_class.id}})
      @{{property_name.id}} = value
    end

  end
  #END HASMANY


end
