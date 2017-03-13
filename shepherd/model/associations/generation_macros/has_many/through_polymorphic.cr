class Shepherd::Model::GenerationMacros::HasMany::ThroughPolymorphic


  macro generate_for_join_builder(master_class, property_name, config, aggregate_config, database_mapping)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    #{% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    #{% through_class = config[:through_class] %}
    #{% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    #{% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}
    {% through = config[:through] %}
    {% alias_on_join_as = config[:alias_on_join_as] %}

    def {{property_name.id}}(*, alias_as : String? = {{alias_on_join_as}}, extra_join_criteria : String? = nil)

      self.inner_join(&.{{through.id}}.inner_join(&.{{that_joined_through.id}}({{slave_class}}, alias_as: alias_as, extra_join_criteria: extra_join_criteria)))

    end

  end


  macro generate_for_eager_loader(owner_class, config, aggregate_config, database_mapping)

    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}

    {% through_relation_name = config[:through]%}
    {% options_for_through_relation = aggregate_config[through_relation_name] %}

    {% local_key_for_through = options_for_through_relation[:local_key] %}
    {% local_key_for_through_config = database_mapping[:column_names][local_key_for_through] %}

    {% local_key_for_through_type = local_key_for_through_config[:type] %}
    {% foreign_key_for_through = options_for_through_relation[:foreign_key] %}
    {% through_class = options_for_through_relation[:class_name] %}

    {% this_joined_through = config[:this_joined_through] %}

    {% this_joins_as = config[:this_joins_as]%}

    def {{property_name.id}}

      repo = {{slave_class}}.repo

      @resolver_proc = Proc(Shepherd::Model::Collection({{owner_class}}), Nil).new do |collection|

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
            .where({{through_class}}, { {{foreign_key_for_through}}, :in, array_of_local_keys })
            {% if this_joins_as %}
              .where({{through_class}}, { {{polymorphic_type_field}}, :eq, {{this_joins_as}} })
            {% end %}
            .list

          child_collection.each do |child|
            mapper_by_local_key[child.{{foreign_key_for_through.id}}].{{property_name.id}}(load: false) << child
          end
        end

      end


      repo
    end

  end


  #Has many through relation:
  # association to through can be plain has_many, plain has_one, or plain belongs_to
  # class that serves as through intermediary is polymorphic, so it has #foo#_type, #foo#_id fields
  # and must be in relation of belongs_to relative to class that being accessed
  # cousins: {
  #   type: :has_many,
  #   class_name: Models::Person #TODO: can be inferred
  #   through: :family,
  #   this_joined_through: family, # person joins family #this visible #TODO: can be infered
  #   that_joined_through: family_member, #family joins family_member #person visible #TODO: can be infered
  #   that_joins_as: "Cousin",
  #   this_joins_as: "Cousin"
  #   polymorphic_type_field: "family_member_type"
  #   polymorphic_id_field: "family_member_id"
  # }
  macro set(master_class, property_name, config, aggregate_config)
    {% slave_class = config[:class_name] || (x = master_class.stringify.split("::"); x[-1] = property_name.id.stringify.camelcase; x.join("::").id) %}
    {% this_joined_through  = config[:this_joined_through] %}
    {% that_joined_through = config[:that_joined_through] %}
    {% through_class = config[:through_class] %}
    {% local_key_for_through =  aggregate_config[config[:through]][:local_key] %}
    {% foreign_key_for_through =  aggregate_config[config[:through]][:foreign_key] %}
    {% polymorphic_type_field = config[:polymorphic_type_field] %}
    {% polymorphic_id_field = config[:polymorphic_id_field] %}
    {% this_joins_as = config[:this_joins_as] %}

    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{through_class}}, {{this_joined_through}}, {{that_joined_through}}, {{local_key_for_through}}, {{foreign_key_for_through}}, {{polymorphic_type_field}},{{this_joins_as}})

    {{@type}}.set_getter_overload_load_false({{property_name}}, {{slave_class}})

    {{@type}}.set_getter_overload_to_yield_repo({{property_name}}, {{slave_class}}, {{foreign_key}}, {{local_key}}, {{foreign_key_for_through}}, {{polymorphic_type_field}}, {{this_joins_as}})

    {{@type}}.macro_set_setter({{property_name}}, {{slave_class}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : Shepherd::Model::Collection({{slave_class}})?

  end


  macro set_getter(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through, polymorphic_type_field, this_joins_as)

    def {{property_name.id}}
      @{{property_name.id}} ||= (
        if @{{ local_key_for_through.id }}
          {{slave_class}}.repo
            .inner_join(&.{{this_joined_through.id}})
            .where({{through_class}}, { {{foreign_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
            {% if this_joins_as %}
              .where({{through_class}}, { {{polymorphic_type_field}}, :eq, {{this_joins_as}} })
            {% end %}
            .list
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


  macro set_getter_overload_to_yield_repo(property_name, slave_class, through_class, this_joined_through, that_joined_through, local_key_for_through, foreign_key_for_through, polymorphic_type_field, this_joins_as)

    def {{property_name.id}}(yield_repo : Bool, &block)
      @{{property_name.id}} ||= (
        yield (
          {{slave_class}}.repo
            .inner_join(&.{{this_joined_through.id}}
            .where({{through_class}}, { {{foreign_key_for_through}}, :eq, self.{{local_key_for_through.id}} })
            {% if this_joins_as %}
              .where({{through_class}}, { {{polymorphic_type_field}}, :eq, {{this_joins_as}} })
            {% end %}
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
