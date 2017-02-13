module Shepherd::Model::Associations::ModulesForModel::AssociationsMapper

  module Macros

    macro associations_config(config)

      {% for association_name, options in config %}
        {% if association_name == :has_many %}
          set_has_many({{options.id}})
        # {%elsif association_name == :has_one && options[:through]}
        #   set_has_one_through({{options.id}})
        {% elsif association_name == :has_one %}
          set_has_one({{options.id}})
        {% elsif association_name == :belongs_to %}
          set_belongs_to({{options.id}})
        {% end %}
      {% end %}

      generate_join_builder({{config}})

      generate_eager_load_builder({{config}})

    end







    ##HASMANY
    macro set_has_many(options)

      {% property_name = options[0] %}
      {% config = options[1] %}
      {% class_name = config[:class_name] %}

      #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_many({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_many_overload_load_false({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_many_overload_to_yield_repository({{property_name}}, {{class_name}}, {{config}})

      macro_set_setter_for_has_many({{property_name}}, {{class_name}}, {{config}})


    end


    macro macro_set_property_for_has_many(property_name, class_name, config)

      #@{{property_name.id}} : Shepherd::Model::Collection({{class_name}})

    end


    macro macro_set_getter_for_has_many(property_name, class_name, config)

      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ config[:local_key].id }}
            {{class_name}}.repository.where(
            {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).execute
          else
            Shepherd::Model::Collection({{class_name}}).new
          end
        ).as(Shepherd::Model::Collection({{class_name}}))
      end

    end


    macro macro_set_getter_for_has_many_overload_load_false(property_name, class_name, config)

      def {{property_name.id}}(*, load : Bool)
        @{{property_name.id}} ||= (
            Shepherd::Model::Collection({{class_name}}).new
        ).as(Shepherd::Model::Collection({{class_name}}))
      end

    end


    macro macro_set_getter_for_has_many_overload_to_yield_repository(property_name, class_name, config)

      def {{property_name.id}}(yield_repository : Bool, &block)
        @{{property_name.id}} ||= (
          yield ({{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
          ))
        )
      end

    end


    macro macro_set_setter_for_has_many(property_name, class_name, config)

      def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
        @{{property_name.id}} = value
      end

    end
    #END HASMANY








    #HAS ONE
    macro set_has_one(options)
      {% property_name = options[0] %}
      {% config = options[1] %}
      {% class_name = config[:class_name] %}

      #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_one({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_one_overload_load_false({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_has_one_overload_to_yield_repository({{property_name}}, {{class_name}}, {{config}})

      macro_set_setter_for_has_one({{property_name}}, {{class_name}}, {{config}})

    end

    macro macro_set_getter_for_has_one(property_name, class_name, config)

      @{{property_name.id}} : {{class_name}}?

      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ config[:local_key].id }}
            {{class_name}}.repository.where(
              {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).execute[0]?
          else
            nil
          end
        )
      end

    end


    macro macro_set_getter_for_has_one_overload_load_false(property_name, class_name, config)

      def {{property_name.id}}(*, load : Bool)
        @{{property_name.id}} ||= (
            nil
        )
      end

    end


    macro macro_set_getter_for_has_one_overload_to_yield_repository(property_name, class_name, config)

      def {{property_name.id}}(yield_repository : Bool, &block)
        @{{property_name.id}} ||= (
          yield ({{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
          ))
        )
      end

    end


    macro macro_set_setter_for_has_one(property_name, class_name, config)

      def {{property_name.id}}=(value : {{class_name.id}}?)
        @{{property_name.id}} = value
      end

    end
    #END HAS ONE






    #BELONGS_TO
    macro set_belongs_to(options)
      {% property_name = options[0] %}
      {% config = options[1] %}
      {% class_name = config[:class_name] %}

      #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_belongs_to({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_belongs_to_overload_load_false({{property_name}}, {{class_name}}, {{config}})

      macro_set_getter_for_belongs_to_overload_to_yield_repository({{property_name}}, {{class_name}}, {{config}})

      macro_set_setter_for_belongs_to({{property_name}}, {{class_name}}, {{config}})

    end

    macro macro_set_getter_for_belongs_to(property_name, class_name, config)

      @{{property_name.id}} : {{class_name}}?

      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ config[:local_key].id }}
            {{class_name}}.repository.where(
              {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).execute[0]?
          else
            nil
          end
        )
      end

    end


    macro macro_set_getter_for_belongs_to_overload_load_false(property_name, class_name, config)

      def {{property_name.id}}(*, load : Bool)
        @{{property_name.id}} ||= (
            nil
        )
      end

    end


    macro macro_set_getter_for_belongs_to_overload_to_yield_repository(property_name, class_name, config)

      def {{property_name.id}}(yield_repository : Bool, &block)
        @{{property_name.id}} ||= (
          yield ({{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
          ))
        )
      end

    end


    macro macro_set_setter_for_belongs_to(property_name, class_name, config)

      def {{property_name.id}}=(value : {{class_name.id}}?)
        @{{property_name.id}} = value
      end

    end

    #END BELONGS_TO





    #HAS_ONE_THROUGH
    # macro set_has_one_through(options)
    #   {% property_name = options[0] %}
    #   {% config = options[1] %}
    #   {% class_name = config[:class_name] %}
    #   {% through_class = config[:through] %}
    #
    #   #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})
    #
    #   macro_set_getter_for_has_one_through({{property_name}}, {{class_name}}, {{config}})
    #
    #   macro_set_getter_for_has_one_through_overload_load_false({{property_name}}, {{class_name}}, {{config}})
    #
    #   macro_set_getter_for_has_one_through_overload_to_yield_repository({{property_name}}, {{class_name}}, {{config}})
    #
    #   macro_set_setter_for_has_one_through({{property_name}}, {{class_name}}, {{config}})
    #
    # end
    #
    # macro macro_set_getter_for_has_one_through(property_name, class_name, config)
    #
    #   @{{property_name.id}} : {{class_name}}?
    #
    #   def {{property_name.id}}
    #     @{{property_name.id}} ||= (
    #       if @{{ config[:local_key].id }}
    #         {{class_name}}.repository.where(
    #           {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
    #         ).execute[0]?
    #       else
    #         nil
    #       end
    #     )
    #   end
    #
    # end
    #
    #
    # macro macro_set_getter_for_has_one_through_overload_load_false(property_name, class_name, config)
    #
    #   def {{property_name.id}}(*, load : Bool)
    #     @{{property_name.id}} ||= (
    #         nil
    #     )
    #   end
    #
    # end
    #
    #
    # macro macro_set_getter_for_has_one_through_overload_to_yield_repository(property_name, class_name, config)
    #
    #   def {{property_name.id}}(yield_repository : Bool, &block)
    #     @{{property_name.id}} ||= (
    #       yield ({{class_name.id}}.repository.where(
    #         {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
    #       ))
    #     )
    #   end
    #
    # end
    #
    #
    # macro macro_set_setter_for_has_one_through(property_name, class_name, config)
    #
    #   def {{property_name.id}}=(value : {{class_name.id}}?)
    #     @{{property_name.id}} = value
    #   end
    #
    # end



    #END HAS_ONE_THROUGH







    #JOIN BUILDER CONFIG GENERATOR
    macro generate_join_builder(config)

      class JoinBuilder < Shepherd::Model::JoinBuilderBase

        include Shepherd::Model::JoinBuilderBase::Interface

        {% for association_name, options in config %}
          {% class_name = options[1][:class_name] %}
          {% local_key = options[1][:local_key] %}
          {% foreign_key = options[1][:foreign_key] %}

          def {{options[0].id}}

            @join_statements << {
              join_type: @join_type,
              parent: {{@type}},
              class_to_join: {{class_name}},
              parent_column: {{local_key}},
              class_to_join_column: {{foreign_key}}
            }

            {{ class_name }}::JoinBuilder.new(@join_type, @join_statements)

          end
        {% end %}

      end

    end

    macro generate_eager_load_builder(config)

      class EagerLoader
        include Shepherd::Model::EagerLoaderInterface
        @resolver_proc : Proc(Shepherd::Model::Collection({{@type}}), Nil)?

        def resolve(collection : Shepherd::Model::Collection({{@type}}))
          @resolver_proc.not_nil!.call(collection)
        end

        {% for association_name, options in config %}
          {% class_name = options[1][:class_name] %}
          {% local_key = options[1][:local_key] %}
          {% foreign_key = options[1][:foreign_key] %}

          def {{options[0].id}}

            repository = {{class_name}}.repository.init_where

            @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
              #TODO: ideally should read types of fields out of results of db_mapping macro
              mapper_by_local_key = {} of Int32 => {{@type}}
              array_of_local_keys = [] of Int32

              collection.each do |model|
                array_of_local_keys << model.id.as(Int32)
                mapper_by_local_key[model.id.as(Int32)] = model
              end

              unless array_of_local_keys.empty?
                child_collection = repository.not_nil!.where({{class_name}}.table_name, { {{foreign_key}}, :in, array_of_local_keys }).execute

                child_collection.each do |child|

                  {% if association_name == :has_many %}
                    mapper_by_local_key[child.{{foreign_key.id}}].{{options[0].id}}(load: false) << child
                  {% elsif association_name == :has_one %}
                    mapper_by_local_key[child.{{foreign_key.id}}].{{options[0].id}} = child
                  {% elsif association_name == :belongs_to %}
                    mapper_by_local_key[child.{{foreign_key.id}}].{{options[0].id}} = child
                  {% end %}

                end
              end

            end

            repository

          end
        {% end %}

      end

    end


  end


end
