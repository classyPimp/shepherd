require "./modules/db_mapping_to_fields_and_db_result_parsing"

class Shepherd::Model::Base


  include Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::Macros
  extend Shepherd::Model::Modules::DBMappingToFieldsAndDBResultParsing::ClassMethods

  def repository : Shepherd::Model::Repository
    Shepherd::Model::Repository(self).new(self)
  end


end
