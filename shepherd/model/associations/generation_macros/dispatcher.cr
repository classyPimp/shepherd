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

      {% if type == :has_many %}
        Shepherd::Model::Associations::GenerationMacros::HasMany::Plain
          .set({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
      {% end %}

    {% end %}


    Shepherd::Model::Associations::GenerationMacros::JoinBuilderGenerator.generate({{owner}}, {{aggregate_config}}, {{database_mapping}})
    generate_eager_load_builder({{aggregate_config}})

  end

end
