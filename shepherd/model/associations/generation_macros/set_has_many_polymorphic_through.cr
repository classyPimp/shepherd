class Shepeherd::Model::Associations::GenerationMacros::SetHasManyPolymorphicThrough


  macro set(master_class, property_name, config, aggregate_config)

    {% slave_class = config[:class_name] %}
    {% local_key = config[:local_key] ? config[:local_key] : "id" %}
    {% foreign_key = config[:foreign_key] ? config[:foreign_key] : "#{master_class.stringify.split("::")[-1].downcase}_id" %}
    {% foreign_polymorphic_field = config[:foreign_polymorphic_field] %}
    {% slave_class_as_value_for_polymorphic_field = config[:as] %}

    {{@type}}.set_property({{property_name}}, {{slave_class}})

    {{@type}}.set_getter({{property_name}}, {{slave_class}}, {{foreign_key}}, {{local_key}}, {{foreign_polymorphic_key}}, {{slave_class_as_value_for_polymorphic_field}})

    {{@type}}.macro_set_getter_for_has_many_as_polymorphic_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

    macro_set_getter_for_has_many_as_polymorphic_overload_to_yield_repository({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

    macro_set_setter_for_has_many_as_polymorphic({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})


  end


  macro set_property(property_name, slave_class)

    @{{property_name.id}} : Shepherd::Model::Collection({{slave_class}})?

  end


  macro set_getter(property_name, slave_class, foreign_key, local_key, foreign_polymorphic_key, slave_class_as_value_for_polymorphic_field)
    def {{property_name.id}} : Shepherd::Model::Collection({{slave_class}})
      @{{property_name.id}} ||= (
        if @{{ local_key.id }}
          {{slave_class}}.repository.where(
            {{slave_class}}.table_name,
            { "{{ foreign_key.id }}", :eq, self.{{ config[:local_key].id }},
            { "{{ foreign_polymorphic_field.id }}", :eq, {{ slave_class_as_value_for_polymorphic_field }} } }
          ).execute
        else
          Shepherd::Model::Collection({{slave_class}}).new
        end
      ).as(Shepherd::Model::Collection({{slave_class}}))
    end

  end


  macro macro_set_getter_for_has_many_as_polymorphic_overload_load_false(property_name, class_name, config, aggregate_config)

    def {{property_name.id}}(*, load : Bool)
      @{{property_name.id}} ||= (
          Shepherd::Model::Collection({{class_name}}).new
      ).as(Shepherd::Model::Collection({{class_name}}))
    end

  end


  macro macro_set_getter_for_has_many_as_polymorphic_overload_to_yield_repository(property_name, class_name, config, aggregate_config)

    def {{property_name.id}}(yield_repository : Bool, &block)
      @{{property_name.id}} ||= (
        yield ({{class_name.id}}.repository.where(
          {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }}, { "{{ config[:foreign_polymorphic_field].id }}", :eq, {{config[:as]}} } }
        ))
      )
    end

  end


  macro macro_set_setter_for_has_many_as_polymorphic(property_name, class_name, config, aggregate_config)

    def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
      @{{property_name.id}} = value
    end

  end
  #END HASMANY



end
