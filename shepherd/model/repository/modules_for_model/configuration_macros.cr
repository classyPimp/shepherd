module Shepherd::Model::Repository::ModulesForModel::ConfigurationMacros

  macro default_repository(settings)
    {% connection = settings[:connection] %}
    {% symbol_adapter = settings[:adapter] %}

    def repository : Shepherd::Model::Repository::Base
      Shepherd::Model::Repository::Base(
        Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}},
        {{connection}},
        self).new(self)
    end

    def self.repository : Shepherd::Model::Repository::Base
      Shepherd::Model::Repository::Base(
        Shepherd::Model::QueryBuilder::Adapters::{{symbol_adapter.id}},
        {{connection}},
        self).new
    end

  end

end
