class Shepherd::Model::Associations::GenerationMacros::Dispatcher

  #has_many
  #has_many through
  #has_many through_polymorphic
  #has_many as_polymorphic

  #has_one
  #has_one through
  #has_one through_polymorphic
  #has_one as_polymorphic

  #belongs_to
  #belongs_to polymorphic


  macro set_associations(owner, aggregate_config, database_mapping)

    {% for property_name, config in aggregate_config %}

      {% type = config[:type] %}

      #HAS_MANY THROUGH POLYMORPHIC
      {% if type == :has_many && config[:through] && config[:polymorphic_type_field] %}
        Shepherd::Model::Associations::GenerationMacros::HasMany::ThroughPolymorphic
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #HAS_MANY THROUGH PLAIN
      {% elsif type == :has_many && config[:through]%}
        Shepherd::Model::Associations::GenerationMacros::HasMany::Through
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #HAS_MANY AS POLYMORPHIC
      {% elsif type == :has_many && config[:foreign_polymorphic_type_field] %}
        Shepherd::Model::Associations::GenerationMacros::HasMany::AsPolymorphic
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #PLAIN
      {% elsif type == :has_many %}
        Shepherd::Model::Associations::GenerationMacros::HasMany::Plain
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      {% end %}


      {% if type == :has_one && config[:through] && config[:polymorphic_type_field] %}
        Shepherd::Model::Associations::GenerationMacros::HasOne::ThroughPolymorphic
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #HAS_MANY THROUGH PLAIN
      {% elsif type == :has_one && config[:through]%}
        Shepherd::Model::Associations::GenerationMacros::HasOne::Through
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #HAS_MANY AS POLYMORPHIC
      {% elsif type == :has_one && config[:foreign_polymorphic_type_field] %}
        Shepherd::Model::Associations::GenerationMacros::HasOne::AsPolymorphic
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      #PLAIN
      {% elsif type == :has_one %}
        Shepherd::Model::Associations::GenerationMacros::HasOne::Plain
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      {% end %}


      {%if type == :belongs_to && config[:polymorphic]%}
        Shepherd::Model::Associations::GenerationMacros::BelongsTo::Polymorphic
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      {%elsif type == :belongs_to%}
        Shepherd::Model::Associations::GenerationMacros::BelongsTo::Plain
          .set({{owner}}, {{property_name.symbolize}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      {%end%}


    {% end %}


    Shepherd::Model::Associations::GenerationMacros::JoinBuilderGenerator.generate({{owner}}, {{aggregate_config}}, {{database_mapping}})
    generate_eager_load_builder({{aggregate_config}})

  end

end
