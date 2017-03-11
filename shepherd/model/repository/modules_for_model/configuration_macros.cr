module Shepherd::Model::Repository::ModulesForModel::ConfigurationMacros

  macro default_repository(settings)
    {% connection = settings[:connection] %}
    {% symbol_adapter = settings[:adapter] %}

    def repo : Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}}::Repository({{connection}}, self)
      Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}}::Repository({{connection}}, self).new(self)
    end

    def self.repo : Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}}::Repository({{connection}}, self)
      Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}}::Repository({{connection}}, self).new
    end

  end

end
