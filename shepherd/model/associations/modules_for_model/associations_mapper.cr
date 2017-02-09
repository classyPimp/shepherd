module Shepherd::Model::ModulesForModel::AssociationsMapper


  module Macros

    macro associations_config(config)

    {% for association_name, options in config %}
        {%if association_name == :has_many%}
          set_has_many({{options.id}})
        {%end%}
      {% end %}

    end



    ##HASMANY
    macro set_has_many(options)

      {% property_name = options[0] %}
      {% config = options[1] %}
      {% class_name = config[:class_name]%}

      macro_set_property_for_has_many(property_name, class_name, config)

      macro_set_getter_for_has_many(property_name, class_name, config)

      macro_set_getter_for_has_many_overload_to_yield_repository(property_name, class_name, config)

      macro_set_setter_for_has_many(property_name, class_name, config)


    end


    macro macro_set_property_for_has_many(property_name, class_name, config)

      @{{property_name.id}} : Shepherd::Model::Collection({{class_name.id}})

    end


    macro macro_set_getter_for_has_many(property_name, class_name, config)
      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ config[:local_key].id }}
            {{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).execute
          else
            Shepherd::Model::collection({{class_name.id}}).new
          end
        )
      end
    end

    macro macro_set_getter_for_has_many_overload_to_yield_repository(property_name, class_name, config)
      def {{property_name.id}}(yield_repository: Bool, &block : )
        @{{property_name.id}} ||= (
          if @{{ config[:local_key].id }}
            {{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).execute
          else
            Shepherd::Model::collection({{class_name.id}}).new
          end
        )
      end
    end

    macro macro_set_setter_for_has_many(property_name, class_name, config)
      def {{property_name.id}}(value : Shepherd::Model::collection({{class_name.id}}))
        @{{property_name.id}} = value
      end
    end
    #END HASMANY



  end


end
