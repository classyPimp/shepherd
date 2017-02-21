class Shepherd::Model::Associations::GenerationMacros::JoinBuilder

  macro generate(owner, aggregate_config, database_mapping)

    def self.join_builder
      JoinBuilder
    end

    class JoinBuilder < Shepherd::Model::JoinBuilderBase

      include Shepherd::Model::JoinBuilderBase::Interface

      {% for property_name, config in aggregate_config %}

        {% type = config[:type] %}

          {%if type == :has_many%}
            Shepherd::Model::GenerationMacros::HasMany::Plain.generate_for_join_builder({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
          {%end%}

        {%end%}

      {%end%}

    end

  end

end
