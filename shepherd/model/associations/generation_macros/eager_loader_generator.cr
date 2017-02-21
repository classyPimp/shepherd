class Shepherd::Model::Associations::GenerationMacros::EagerLoader

  macro generate(owner, aggregate_config, database_mapping)

    class EagerLoader
      include Shepherd::Model::EagerLoaderInterface
      @resolver_proc : Proc(Shepherd::Model::Collection({{owner}}), Nil)?

      def resolve(collection : Shepherd::Model::Collection({{owner}}))
        @resolver_proc.not_nil!.call(collection)
      end

      {% for property_name, config in aggregate_config %}

        {% type = config[:type] %}

          {%if type == :has_many%}
            Shepherd::Model::GenerationMacros::HasMany::Plain.generate_for_eager_loader({{owner}}, {{property_name}}, {{config}}, {{aggregate_config}}, {{database_mapping}})
          {%end%}

        {%end%}

      {%end%}

    end
    
  end

end
