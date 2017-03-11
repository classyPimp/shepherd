require "./modules/db_mapping_to_fields_and_db_result_parsing"
require "./associations/modules_for_model/associations_mapper"
require "./repository/modules_for_model/configuration_macros"

class Shepherd::Model::Base

  @@table_name : String
  @@table_name = ""


  include Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::Macros
  extend Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::ClassMethods

  include Shepherd::Model::Associations::ModulesForModel::AssociationsMapper::Macros

  include Shepherd::Model::Repository::ModulesForModel::ConfigurationMacros

  #TODO : implement repository interface
  def repo : Shepherd::Model::Repository::Base
  end

  def self.repo : Shepherd::Model::Repository::Base
  end

end
