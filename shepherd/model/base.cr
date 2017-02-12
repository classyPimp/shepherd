require "./modules/db_mapping_to_fields_and_db_result_parsing"
require "./associations/modules_for_model/associations_mapper"

class Shepherd::Model::Base

  @@table_name : String
  @@table_name = ""
  
  include Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::Macros
  extend Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::ClassMethods

  include Shepherd::Model::Associations::ModulesForModel::AssociationsMapper::Macros

  def repository : Shepherd::Model::Repository
    Shepherd::Model::Repository(self).new(self)
  end

  def self.repository : Shepherd::Model::Repository
    Shepherd::Model::Repository(self).new
  end

end
