class Shepherd::Model::Associations::GenerationMacros::EagerLoader

  macro generate(owner, aggregate_config, database_mapping)

    class EagerLoader

      include Shepherd::Model::EagerLoaderInterface
      @resolver_proc : Proc(Shepherd::Model::Collection({{owner}}), Nil)?

      def resolve(collection : Shepherd::Model::Collection({{owner}}))
        @resolver_proc.not_nil!.call(collection)
      end

      {% for property_name, config in aggregate_config %}
        {% property_name = property_name.id.symbolize %}
        {% type = config[:type] %}

        #HAS_MANY THROUGH POLYMORPHIC
        {% if type == :has_many && config[:through] && config[:polymorphic_type_field] %}
          Shepherd::Model::Associations::GenerationMacros::HasMany::ThroughPolymorphic
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #HAS_MANY THROUGH PLAIN
        {% elsif type == :has_many && config[:through]%}
          Shepherd::Model::Associations::GenerationMacros::HasMany::Through
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #HAS_MANY AS POLYMORPHIC
        {% elsif type == :has_many && config[:foreign_polymorphic_type_field] %}
          Shepherd::Model::Associations::GenerationMacros::HasMany::AsPolymorphic
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #PLAIN
        {% elsif type == :has_many %}
          Shepherd::Model::Associations::GenerationMacros::HasMany::Plain
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        {% end %}


        {% if type == :has_one && config[:through] && config[:polymorphic_type_field] %}
          Shepherd::Model::Associations::GenerationMacros::HasOne::ThroughPolymorphic
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #HAS_MANY THROUGH PLAIN
        {% elsif type == :has_one && config[:through]%}
          Shepherd::Model::Associations::GenerationMacros::HasOne::Through
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #HAS_MANY AS POLYMORPHIC
        {% elsif type == :has_one && config[:foreign_polymorphic_type_field] %}
          Shepherd::Model::Associations::GenerationMacros::HasOne::AsPolymorphic
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        #PLAIN
        {% elsif type == :has_one %}
          Shepherd::Model::Associations::GenerationMacros::HasOne::Plain
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        {% end %}


        {% if type == :belongs_to && config[:polymorphic] %}
          Shepherd::Model::Associations::GenerationMacros::BelongsTo::Polymorphic
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        {% elsif type == :belongs_to %}
          Shepherd::Model::Associations::GenerationMacros::BelongsTo::Plain
            .generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
        {% end %}

      {% end %}

    end

  end

end
