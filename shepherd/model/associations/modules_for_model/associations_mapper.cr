module Shepherd::Model::Associations::ModulesForModel::AssociationsMapper

  module Macros

      macro associations_config(aggregate_config)

        Shepherd::Model::Associations::GenerationMacros::Dispatcher.set_associations({{@type}}, {{aggregate_config}}, {{DATABASE_MAPPING}})
        # {% for property_name, config in aggregate_config %}
        #
        #   {% type = config[:type] %}
        #
        #   {% if type == :has_many && config[:through] && config[:polymorphic_through]%}
        #     set_has_many_through_polymorphic({{property_name.symbolize}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :has_many && config[:as] %}
        #     set_has_many_as_polymorphic({{property_name.symbolize}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :has_many && config[:through] != nil %}
        #     set_has_many_through({{property_name.symbolize}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :has_many %}
        #     set_has_many({{property_name}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :has_one %}
        #     set_has_one({{property_name}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :belongs_to && config[:polymorphic] %}
        #     set_belongs_to_polymorphic({{property_name}}, {{config}}, {{aggregate_config}})
        #
        #   {% elsif type == :belongs_to %}
        #     set_belongs_to({{property_name}}, {{config}}, {{aggregate_config}})
        #
        #   {% end %}
        #
        # {% end %}
        #
        # generate_join_builder({{aggregate_config}})
        # generate_eager_load_builder({{aggregate_config}})

      end








      ##HASMANY AS POLYMORHIC
      macro set_has_many_as_polymorphic(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}

        #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

        macro_set_getter_for_has_many_as_polymorphic({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_as_polymorphic_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_as_polymorphic_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_has_many_as_polymorphic({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})


      end


      macro macro_set_property_for_has_many_as_polymorphic(property_name, class_name, config, aggregate_config)

        #@{{property_name.id}} : Shepherd::Model::Collection({{class_name}})

      end


      macro macro_set_getter_for_has_many_as_polymorphic(property_name, class_name, config, aggregate_config)
        def {{property_name.id}}
          @{{property_name.id}} ||= (
            if @{{ config[:local_key].id }}
              {{class_name}}.repo.where(
              {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }}, { "{{ config[:foreign_polymorphic_field].id }}", :eq, {{config[:as]}} } }
              ).get
            else
              Shepherd::Model::Collection({{class_name}}).new
            end
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_as_polymorphic_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              Shepherd::Model::Collection({{class_name}}).new
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_as_polymorphic_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo.where(
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

















      #HASMANY THROUGH POLYMORPHIC
      macro set_has_many_through_polymorphic(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}

        macro_set_getter_for_has_many_through_polymorphic({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_through_polymorphic_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_through_polymorphic_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_has_many_through_polymorphic({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})


      end


      macro macro_set_property_for_has_many_through_polymorphic(property_name, class_name, config, aggregate_config)

        #@{{property_name.id}} : Shepherd::Model::Collection({{class_name}})

      end


      macro macro_set_getter_for_has_many_through_polymorphic(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}
          {% if config[:this_joined_as] %}
            extra_join_criteria = " AND #{{{aggregate_config[config[:through]][:class_name]}}.table_name}.{{config[:polymorphic_type_field].id}} = '{{config[:this_joined_as].id}}' "
          {%else%}
            extra_join_criteria = nil
          {% end %}

          @{{property_name.id}} ||= (
            if @{{ aggregate_config[config[:through]][:local_key].id }}
              {{class_name}}.repo
                .inner_join(&.{{config[:this_joined_through].id}}(extra_join_criteria: extra_join_criteria))
                .where({{aggregate_config[config[:through]][:class_name]}}, { {{aggregate_config[config[:through]][:foreign_key]}}, :eq, self.{{aggregate_config[config[:through]][:local_key].id}} })
                .get
            else
              Shepherd::Model::Collection({{class_name}}).new
            end
          ).as(Shepherd::Model::Collection({{class_name}}))
        end
      end


      macro macro_set_getter_for_has_many_through_polymorphic_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              Shepherd::Model::Collection({{class_name}}).new
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_through_polymorphic_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo
              .inner_join(&.{{config[:this_joined_through].id}})
              .where({{aggregate_config[config[:through]][:class_name]}}, { {{aggregate_config[config[:through]][:foreign_key]}}, :eq, {{aggregate_config[config[:through]][:foreign_key]}} })
            )
          )
        end

      end


      macro macro_set_setter_for_has_many_through_polymorphic(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
          @{{property_name.id}} = value
        end

      end













      #BELONGS_TO_POLYMORPHIC
      macro set_belongs_to_polymorphic(property_name, config, aggregate_config)

        macro_set_getter_for_belongs_to_polymorphic({{property_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_belongs_to_polymorphic_overload_load_false({{property_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_belongs_to_polymorphic_overload_to_yield_repo({{property_name.symbolize}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_belongs_to_polymorphic({{property_name.symbolize}}, {{config}}, {{aggregate_config}})

      end

      macro macro_set_getter_for_belongs_to_polymorphic(property_name, config, aggregate_config)

        @{{property_name.id}} : ({{config[:supported_types]}})?

        {% separate_types_ary_of_str = config[:supported_types].stringify.split('|').map(&.strip) %}

        def {{property_name.id}}
          @{{property_name.id}} ||= (
            if @{{ config[:local_key].id }}
              case @{{config[:polymorphic_type_field].id}}
              {% for str_type in separate_types_ary_of_str %}
              when {{ str_type.split("::")[-1] }}
                {{str_type.id}}.repo.where(
                   {{str_type.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
                 ).limit(1).get[0]?
              {% end %}
              end
            else
              nil
            end
          )
        end

      end


      macro macro_set_getter_for_belongs_to_polymorphic_overload_load_false(property_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              nil
          )
        end

      end


      macro macro_set_getter_for_belongs_to_polymorphic_overload_to_yield_repo(property_name, config, aggregate_config)
        def {{property_name.id}}(yield_repo : Bool, &block)
          {% separate_types_ary_of_str = config[:supported_types].stringify.split('|').map(&.strip) %}
          @{{property_name.id}} ||= (
            case @{{config[:polymorphic_type_field].id}}
            {% for str_type in separate_types_ary_of_str %}
            when {{ str_type.split("::")[-1] }}
              yield ({{str_type.id}}.repo.where(
                {{str_type.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
              ).limit(1))
            {% end %}
            end
          )
        end

      end


      macro macro_set_setter_for_belongs_to_polymorphic(property_name, config, aggregate_config)

        def {{property_name.id}}=(value : {{config[:supported_types]}}?)
          @{{property_name.id}} = value
        end

      end

      #END BELONGS_TO_POLYMORPHIC

















      macro set_has_many_through(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}

        macro_set_getter_for_has_many_through({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_through_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_through_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_has_many_through({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})


      end


      macro macro_set_property_for_has_many_through(property_name, class_name, config, aggregate_config)

        #@{{property_name.id}} : Shepherd::Model::Collection({{class_name}})

      end


      macro macro_set_getter_for_has_many_through(property_name, class_name, config, aggregate_config)
        def {{property_name.id}}
          {% if config[:this_joined_as] %}
            extra_join_criteria = " AND #{{{aggregate_config[config[:through]][:class_name].id}}.table_name}.{{aggregate_config[config[:through]][:foreign_polymorphic_field].id}} = '{{config[:this_joined_as].id}}'"
          {% else %}
            extra_join_criteria = nil
          {% end %}

          @{{property_name.id}} ||= (
            if @{{ aggregate_config[config[:through]][:local_key].id }}
              {{class_name}}.repo
                .inner_join(&.{{config[:this_joined_through].id}}(extra_join_criteria: extra_join_criteria))
                .where({{aggregate_config[config[:through]][:class_name]}}, { {{aggregate_config[config[:through]][:foreign_key]}}, :eq, self.{{aggregate_config[config[:through]][:local_key].id}} })
                .get
            else
              Shepherd::Model::Collection({{class_name}}).new
            end
          ).as(Shepherd::Model::Collection({{class_name}}))
        end
      end


      macro macro_set_getter_for_has_many_through_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              Shepherd::Model::Collection({{class_name}}).new
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_through_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo
              .inner_join(&.{{config[:this_joined_through].id}})
              .where({{aggregate_config[config[:through]][:class_name]}}, { {{aggregate_config[config[:through]][:foreign_key]}}, :eq, {{aggregate_config[config[:through]][:foreign_key]}} })
            )
          )
        end

      end


      macro macro_set_setter_for_has_many_through(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
          @{{property_name.id}} = value
        end

      end












      ##HASMANY
      macro set_has_many(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}

        #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

        macro_set_getter_for_has_many({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_many_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_has_many({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})


      end


      macro macro_set_property_for_has_many(property_name, class_name, config, aggregate_config)

        #@{{property_name.id}} : Shepherd::Model::Collection({{class_name}})

      end


      macro macro_set_getter_for_has_many(property_name, class_name, config, aggregate_config)
        def {{property_name.id}}
          @{{property_name.id}} ||= (
            if @{{ config[:local_key].id }}
              {{class_name}}.repo.where(
              {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
              ).get
            else
              Shepherd::Model::Collection({{class_name}}).new
            end
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              Shepherd::Model::Collection({{class_name}}).new
          ).as(Shepherd::Model::Collection({{class_name}}))
        end

      end


      macro macro_set_getter_for_has_many_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo.where(
              {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ))
          )
        end

      end


      macro macro_set_setter_for_has_many(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}=(value : Shepherd::Model::Collection({{class_name.id}}))
          @{{property_name.id}} = value
        end

      end
      #END HASMANY









      #HAS ONE
      macro set_has_one(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}
        #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})
        macro_set_getter_for_has_one({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_one_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_has_one_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_has_one({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

      end

      macro macro_set_getter_for_has_one(property_name, class_name, config, aggregate_config)

        @{{property_name.id}} : {{class_name}}?

        def {{property_name.id}}
          @{{property_name.id}} ||= (
            if @{{ config[:local_key].id }}
              {{class_name}}.repo.where(
                {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
              ).limit(1).get[0]?
            else
              nil
            end
          )
        end

      end


      macro macro_set_getter_for_has_one_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              nil
          )
        end

      end


      macro macro_set_getter_for_has_one_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo.where(
              {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).limit(1))
          )
        end

      end


      macro macro_set_setter_for_has_one(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}=(value : {{class_name.id}}?)
          @{{property_name.id}} = value
        end

      end
      #END HAS ONE






      #BELONGS_TO
      macro set_belongs_to(property_name, config, aggregate_config)

        {% class_name = config[:class_name] %}

        #macro_set_property_for_has_many({{property_name}}, {{class_name}}, {{config}})

        macro_set_getter_for_belongs_to({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_belongs_to_overload_load_false({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_getter_for_belongs_to_overload_to_yield_repo({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

        macro_set_setter_for_belongs_to({{property_name}}, {{class_name}}, {{config}}, {{aggregate_config}})

      end

      macro macro_set_getter_for_belongs_to(property_name, class_name, config, aggregate_config)

        @{{property_name.id}} : {{class_name}}?

        def {{property_name.id}}
          @{{property_name.id}} ||= (
            if @{{ config[:local_key].id }}
              {{class_name}}.repo.where(
                {{class_name}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
              ).limit(1).get[0]?
            else
              nil
            end
          )
        end

      end


      macro macro_set_getter_for_belongs_to_overload_load_false(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(*, load : Bool)
          @{{property_name.id}} ||= (
              nil
          )
        end

      end


      macro macro_set_getter_for_belongs_to_overload_to_yield_repo(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}(yield_repo : Bool, &block)
          @{{property_name.id}} ||= (
            yield ({{class_name.id}}.repo.where(
              {{class_name.id}}.table_name, { "{{config[:foreign_key].id}}", :eq, self.{{ config[:local_key].id }} }
            ).limit(1))
          )
        end

      end


      macro macro_set_setter_for_belongs_to(property_name, class_name, config, aggregate_config)

        def {{property_name.id}}=(value : {{class_name.id}}?)
          @{{property_name.id}} = value
        end

      end

      #END BELONGS_TO








      #JOIN BUILDER CONFIG GENERATOR
      macro generate_join_builder(aggregate_config)

        def self.join_builder
          JoinBuilder
        end

        class JoinBuilder < Shepherd::Model::JoinBuilderBase

          include Shepherd::Model::JoinBuilderBase::Interface

          {% for property_name, options in aggregate_config %}


            {% if options[:type] == :has_many && options[:through] && options[:polymorphic_through]%}

              def {{property_name.id}}(*, alias_as : String? = {{options[:alias_on_join_as]}}, extra_join_criteria : String? = nil)

                self.inner_join(&.{{options[:through].id}}.inner_join(&.{{options[:source].id}}({{options[:class_name].id}}, alias_as: alias_as, extra_join_criteria: extra_join_criteria)))

              end

            {% elsif options[:type] == :has_many && options[:as] %}

              def {{property_name.id}}(*, alias_as : String? = nil, extra_join_criteria : String? = " AND #{{{options[:class_name].id}}.table_name}.{{options[:foreign_polymorphic_field].id}} = '{{options[:as].id}}' ")

                @join_statements << {
                  join_type: @join_type,
                  parent: {{@type}},
                  class_to_join: {{options[:class_name]}},
                  parent_column: {{options[:local_key]}},
                  class_to_join_column: {{options[:foreign_key]}},
                  alias_as: alias_as,
                  extra_join_criteria: extra_join_criteria
                }

                {{options[:class_name]}}::JoinBuilder.new(@join_type, @join_statements)

              end

            {% elsif options[:through] %}

              def {{property_name.id}}(*, alias_as : String? = {{options[:alias_on_join_as]}}, extra_join_criteria : String? = nil)

                self.inner_join(&.{{options[:through].id}}.inner_join(&.{{options[:source].id}}(alias_as: alias_as, extra_join_criteria: extra_join_criteria)))

              end

            {% elsif options[:type] == :belongs_to && options[:polymorphic] %}

              {% supported_types_ary = options[:supported_types].stringify.split('|').map(&.strip) %}
              {% for type in supported_types_ary %}
                def {{property_name.id}}(class_to_join : {{type.id}}.class, alias_as : String? = nil, extra_join_criteria : String? = " AND #{{{@type}}.table_name}.{{options[:polymorphic_type_field].id}} = '{{type.split("::")[-1].id}}' ")

                  @join_statements << {
                    join_type: @join_type,
                    parent: {{@type}},
                    class_to_join: {{type.id}},
                    parent_column: {{options[:local_key]}},
                    class_to_join_column: {{options[:foreign_key]}},
                    alias_as: alias_as,
                    extra_join_criteria: extra_join_criteria
                  }

                  {{type.id}}::JoinBuilder.new(@join_type, @join_statements)

                end
              {% end %}

            {% else %}

              {% class_name = options[:class_name] %}
              {% local_key = options[:local_key] %}
              {% foreign_key = options[:foreign_key] %}

              def {{property_name.id}}(*, alias_as : String? = {{options[:alias_on_join_as]}}, extra_join_criteria : String? = nil)

                @join_statements << {
                  join_type: @join_type,
                  parent: {{@type}},
                  class_to_join: {{class_name}},
                  parent_column: {{local_key}},
                  class_to_join_column: {{foreign_key}},
                  alias_as: alias_as,
                  extra_join_criteria: extra_join_criteria
                }

                {{ class_name }}::JoinBuilder.new(@join_type, @join_statements)

              end
            {% end %}

          {% end %}

        end

      end

      macro generate_eager_load_builder(aggregate_config)

        class EagerLoader
          include Shepherd::Model::EagerLoaderInterface
          @resolver_proc : Proc(Shepherd::Model::Collection({{@type}}), Nil)?

          def resolve(collection : Shepherd::Model::Collection({{@type}}))
            @resolver_proc.not_nil!.call(collection)
          end

          {% for property_name, options in aggregate_config %}

            {% type = options[:type] %}

              def {{property_name.id}}
                {% if type == :has_many && options[:through] && options[:polymorphic_through]%}
                  #TODO: some better name should be given
                  {% through_ass_options = aggregate_config[options[:through]] %}
                  {% local_key_options = DATABASE_MAPPING[:column_names][through_ass_options[:local_key]]%}

                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{through_ass_options[:local_key].id}} && model.{{options[:polymorphic_type_field].id}} == {{options[:class_name].stringify.split("::")[-1]}}
                        array_of_local_keys << model.{{through_ass_options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{through_ass_options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!.inner_join(&.{{options[:this_joined_through].id}})
                        .where({{through_ass_options[:class_name]}}, { {{through_ass_options[:foreign_key]}}, :in, array_of_local_keys })
                        .where({{through_ass_options[:class_name]}}, { {{options[:polymorphic_type_field]}}, :eq, {{options[:class_name].stringify.split("::")[-1]}} })
                        .get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{through_ass_options[:foreign_key].id}}].{{property_name.id}}(load: false) << child
                      end
                    end

                  end

                  repo

                {% elsif type == :has_many && options[:as] %}

                  {% local_key_options = DATABASE_MAPPING[:column_names][options[:local_key]]%}
                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{options[:local_key].id}}
                        array_of_local_keys << model.{{options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!
                        .where({{options[:class_name]}}.table_name, { {{options[:foreign_key]}}, :in, array_of_local_keys })
                        .where({{options[:class_name]}}.table_name, { {{options[:foreign_polymorphic_field]}}, :eq, {{options[:as]}} })
                        .get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{options[:foreign_key].id}}].{{property_name.id}}(load: false) << child
                      end
                    end

                  end

                  repo

                {% elsif type == :has_many && options[:through] %}

                  {% through_ass_options = aggregate_config[options[:through]] %}
                  {% local_key_options = DATABASE_MAPPING[:column_names][through_ass_options[:local_key]]%}

                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{through_ass_options[:local_key].id}}
                        array_of_local_keys << model.{{through_ass_options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{through_ass_options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!.inner_join(&.{{options[:this_joined_through].id}})
                        .where({{through_ass_options[:class_name]}}, { {{through_ass_options[:foreign_key]}}, :in, array_of_local_keys })
                        .get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{through_ass_options[:foreign_key].id}}].{{property_name.id}}(load: false) << child
                      end
                    end

                  end

                  repo

                {% elsif type == :has_many %}
                  {% local_key_options = DATABASE_MAPPING[:column_names][options[:local_key]]%}
                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{options[:local_key].id}}
                        array_of_local_keys << model.{{options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!.where({{options[:class_name]}}.table_name, { {{options[:foreign_key]}}, :in, array_of_local_keys }).get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{options[:foreign_key].id}}].{{property_name.id}}(load: false) << child
                      end
                    end

                  end

                  repo

                {% elsif type == :has_one%}
                  {% local_key_options = DATABASE_MAPPING[:column_names][options[:local_key]]%}
                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{options[:local_key].id}}
                        array_of_local_keys << model.{{options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!.where({{options[:class_name]}}.table_name, { {{options[:foreign_key]}}, :in, array_of_local_keys }).get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{options[:foreign_key].id}}].{{property_name.id}} = child
                      end
                    end

                  end

                  repo
                {% elsif type == :belongs_to && options[:polymorphic] %}
                  {% local_key_options = DATABASE_MAPPING[:column_names][options[:local_key]]%}
                  {% separate_types_ary_of_str = options[:supported_types].stringify.split('|').map(&.strip) %}

                  repositories = {
                    {% separate_types_ary_of_str_size_flag = separate_types_ary_of_str.size %}
                    {% iterations_counter_flag = 0 %}
                    {% for type in separate_types_ary_of_str%}
                      {% iterations_counter_flag = iterations_counter_flag + 1 %}
                      {{type.split("::")[-1]}}: {{type.id}}.repo {{",".id unless iterations_counter_flag == separate_types_ary_of_str_size_flag }}
                    {% end %}
                  }

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {
                      {% separate_types_ary_of_str_size_flag = separate_types_ary_of_str.size %}
                      {% iterations_counter_flag = 0 %}
                      {% for type in separate_types_ary_of_str%}
                        {% iterations_counter_flag = iterations_counter_flag + 1 %}
                        {{type.split("::")[-1]}}: Hash({{local_key_options[:type]}}, {{@type}}).new(initial_capacity: 20) {{",".id unless iterations_counter_flag == separate_types_ary_of_str_size_flag }}
                      {% end %}
                    }
                    arrays_of_local_keys = {
                      {% separate_types_ary_of_str_size_flag = separate_types_ary_of_str.size %}
                      {% iterations_counter_flag = 0 %}
                      {% for type in separate_types_ary_of_str%}
                        {% iterations_counter_flag = iterations_counter_flag + 1 %}
                        {{type.split("::")[-1]}}: Array({{local_key_options[:type]}}).new(20) {{",".id unless iterations_counter_flag == separate_types_ary_of_str_size_flag }}
                      {% end %}
                    }

                    collection.each do |model|
                      if model.{{options[:local_key].id}}
                        arrays_of_local_keys[model.friend_type.not_nil!] << model.{{options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.friend_type.not_nil!][model.{{options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    arrays_of_local_keys.each do |name, array_of_local_keys|
                      unless array_of_local_keys.empty?
                        child_collection = repositories[name].not_nil!.where( { {{options[:foreign_key]}}, :in, array_of_local_keys }).get
                        child_collection.each do |child|
                          mapper_by_local_key[name][child.{{options[:foreign_key].id}}.not_nil!].{{property_name.id}} = child
                        end
                      end
                    end

                  end

                  repositories

                {% elsif type == :belongs_to %}
                  {% local_key_options = DATABASE_MAPPING[:column_names][options[:local_key]]%}
                  repo = {{options[:class_name]}}.repo

                  @resolver_proc = Proc(Shepherd::Model::Collection({{@type}}), Nil).new do |collection|
                    #TODO: ideally should read types of fields out of results of db_mapping macro
                    mapper_by_local_key = {} of {{local_key_options[:type]}} => {{@type}}
                    array_of_local_keys = [] of {{local_key_options[:type]}}

                    collection.each do |model|
                      if model.{{options[:local_key].id}}
                        array_of_local_keys << model.{{options[:local_key].id}}.not_nil!
                        mapper_by_local_key[model.{{options[:local_key].id}}.not_nil!] = model
                      end
                    end

                    unless array_of_local_keys.empty?
                      child_collection = repo.not_nil!.where({{options[:class_name]}}.table_name, { {{options[:foreign_key]}}, :in, array_of_local_keys }).get

                      child_collection.each do |child|
                        mapper_by_local_key[child.{{options[:foreign_key].id}}].{{property_name.id}} = child
                      end
                    end

                  end

                  repo
                {% end %}

              end

          {% end %}

        end

      end


    end


end
