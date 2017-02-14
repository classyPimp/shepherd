module Shepherd::Model::Associations::ModulesForModel::AssociationsMapper

  module Macros

    macro associations_config(&block)
      HACKY_ASSOCIATION_CONFIG_PROXY = [] of String

      {{block.body}}

      generate_join_builder_class
      generate_eager_loader_class


    end


    macro has_many(property_name, *, class_name, local_key = "id", foreign_key = false)

      {% foreign_key = foreign_key ? foreign_key : "#{@type.name.split("::")[-1].downcase}_id" %}

      {% HACKY_ASSOCIATION_CONFIG_PROXY << "{ type: :has_many, property_name: #{property_name}, class_name: #{class_name}, local_key: #{local_key}, foreign_key: #{foreign_key} }" %}

      {{ property_name.stringify.upcase[1..-1].id }}_ASSOCIATION_CONFIG = {class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}} }

      set_getter_for_has_many({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_getter_for_has_many_overload_load_false({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_getter_for_has_many_overload_to_yield_repository({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_setter_for_has_many({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})

    end


    macro set_getter_for_has_many(property_name, *, class_name, local_key, foreign_key)
      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ local_key.id }}
            {{class_name}}.repository.where(
              {{class_name}}.table_name, { {{ foreign_key }}, :eq, self.{{ local_key.id }} }
            ).execute
          else
            Shepherd::Model::Collection({{class_name}}).new
          end
        ).as(Shepherd::Model::Collection({{class_name}}))
      end
    end

    macro set_getter_for_has_many_overload_load_false(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}(*, load : Bool)
        @{{property_name.id}} ||= (
            Shepherd::Model::Collection({{class_name}}).new
        ).as(Shepherd::Model::Collection({{class_name}}))
      end

    end

    macro set_getter_for_has_many_overload_to_yield_repository(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}(yield_repository : Bool, &block)
        @{{property_name.id}} ||= (
          yield ({{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { {{ foreign_key }}, :eq, self.{{ local_key.id }} }
          ))
        )
      end

    end

    macro set_setter_for_has_many(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
        @{{property_name.id}} = value
      end

    end







    macro has_one(property_name, *, class_name, local_key, foreign_key = false)
      {% foreign_key = foreign_key ? foreign_key : "#{@type.name.split("::")[-1].downcase}_id" %}

      {% HACKY_ASSOCIATION_CONFIG_PROXY << "{ type: :has_many, property_name: #{property_name}, class_name: #{class_name}, local_key: #{local_key}, foreign_key: #{foreign_key} }" %}

      {{  property_name.stringify.upcase[1..-1].id  }}_ASSOCIATION_CONFIG = {class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}} }

      set_getter_for_has_one({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_getter_for_has_one_overload_load_false({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_getter_for_has_one_overload_to_yield_repository({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
      set_setter_for_has_one({{property_name}}, class_name: {{class_name}}, local_key: {{local_key}}, foreign_key: {{foreign_key}})
    end


    macro set_getter_for_has_one(property_name, *, class_name, local_key, foreign_key)

      @{{property_name.id}} : {{class_name}}?

      def {{property_name.id}}
        @{{property_name.id}} ||= (
          if @{{ local_key.id }}
            {{class_name}}.repository.where(
              {{class_name}}.table_name, { {{foreign_key}}, :eq, self.{{ local_key.id }} }
            ).execute[0]?
          else
            nil
          end
        )
      end

    end


    macro set_getter_for_has_one_overload_load_false(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}(*, load : Bool)
        @{{property_name.id}} ||= (
            nil
        )
      end

    end


    macro set_getter_for_has_one_overload_to_yield_repository(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}(yield_repository : Bool, &block)
        @{{property_name.id}} ||= (
          yield ({{class_name.id}}.repository.where(
            {{class_name.id}}.table_name, { {{foreign_key }}, :eq, self.{{ local_key.id }} }
          ))
        )
      end

    end


    macro set_setter_for_has_one(property_name, *, class_name, local_key, foreign_key)

      def {{property_name.id}}=(value : {{class_name.id}}?)
        @{{property_name.id}} = value
      end

    end








    macro generate_join_builder_class

      class JoinBuilder < Shepherd::Model::JoinBuilderBase

        include Shepherd::Model::JoinBuilderBase::Interface
        {% for config in HACKY_ASSOCIATION_CONFIG_PROXY %}
          {{@type}}.dispatch_to_patcher_of_join_builder({{config.id}})
        {% end %}

      end

    end

    macro dispatch_to_patcher_of_join_builder(config)
      {% if config[:type] == :has_many %}
        {{@type}}.patch_join_builder_for_has_many({{config}})
      {% elsif config[:type] == :has_one %}
        {{@type}}.patch_join_builder_for_has_one({{config}})
      {% end %}
    end

    macro patch_join_builder_for_has_many(config)
      def {{config[:property_name].id}}
        @join_statements << {
          join_type: @join_type,
          parent: {{@type}},
          class_to_join: {{config[:class_name].id}},
          parent_column: {{config[:local_key]}},
          class_to_join_column: {{config[:foreign_key]}}
        }
        {{ config[:class_name] }}::JoinBuilder.new(@join_type, @join_statements)
      end
    end

    macro patch_join_builder_for_has_one(config)
      def {{config[:property_name].id}}
        @join_statements << {
          join_type: @join_type,
          parent: {{@type}},
          class_to_join: {{config[:class_name].id}},
          parent_column: {{config[:local_key]}},
          class_to_join_column: {{config[:foreign_key]}}
        }
        {{ config[:class_name] }}::JoinBuilder.new(@join_type, @join_statements)
      end
    end





    macro generate_eager_loader_class

      class EagerLoader
        include Shepherd::Model::EagerLoaderInterface
        @resolver_proc : Proc(Shepherd::Model::Collection({{@type}}), Nil)?

        def resolve(collection : Shepherd::Model::Collection({{@type}}))
          @resolver_proc.not_nil!.call(collection)
        end

        {% for config in HACKY_ASSOCIATION_CONFIG_PROXY %}
          {{@type}}.dispatch_to_patcher_of_eager_loader({{config.id}})
        {% end %}

      end

    end


    macro dispatch_to_patcher_of_eager_loader(config)

      {% if config[:type] == :has_many %}
        {{@type}}.patch_eager_loader_for_has_many({{config}})
      {% elsif config[:type] == :has_one %}
        {{@type}}.patch_eager_loader_for_has_one({{config}})
      {% end %}
    end

    macro patch_eager_loader_for_has_many(config)

      def {{config[:property_name].id}}

        repository = {{config[:class_name].id}}.repository.init_where

        @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
          #TODO: ideally should read types of fields out of results of db_mapping macro
          mapper_by_local_key = {} of Int32 => {{@type}} #TODO: !!!!!!!!!KEY TYPE SHOULD BE GOTTEN FROM DATABASE MAPPING CONFIG!
          array_of_local_keys = [] of Int32

          collection.each do |model|
            array_of_local_keys << model.id.as(Int32)
            mapper_by_local_key[model.id.as(Int32)] = model
          end

          unless array_of_local_keys.empty?
            child_collection = repository.not_nil!.where({{config[:class_name].id}}.table_name, { {{config[:foreign_key]}}, :in, array_of_local_keys }).execute

            child_collection.each do |child|
              mapper_by_local_key[child.{{config[:foreign_key].id}}].{{config[:property_name].id}}(load: false) << child
            end

          end

        end

        repository

      end
    end

    macro patch_eager_loader_for_has_one(config)
      repository = {{config[:class_name].id}}.repository.init_where

      @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
        #TODO: ideally should read types of fields out of results of db_mapping macro
        mapper_by_local_key = {} of Int32 => {{@type}} #TODO: !!!!!!!!!KEY TYPE SHOULD BE GOTTEN FROM DATABASE MAPPING CONFIG!
        array_of_local_keys = [] of Int32

        collection.each do |model|
          array_of_local_keys << model.id.as(Int32)
          mapper_by_local_key[model.id.as(Int32)] = model
        end

        unless array_of_local_keys.empty?
          child_collection = repository.not_nil!.where({{config[:class_name].id}}.table_name, { {{config[:foreign_key]}}, :in, array_of_local_keys }).execute

          child_collection.each do |child|
            mapper_by_local_key[child.{{config[:foreign_key].id}}].{{config[:property_name].id}} = child
          end

        end

      end

      repository

    end


  end


end
