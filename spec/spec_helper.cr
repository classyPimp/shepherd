require "spec"


require "../shepherd/**"
require "../config/**"

Shepherd::Configuration::General.env = ::Config::Env::Test.new

require "../initializers/database_connection"
require "../initializers/midleware"

require "./controllers/preparation/*"

Shepherd::Initializers::Main.start_application

require "./model/associations/belongs_to/plain_spec"
require "./model/associations/belongs_to/polymorphic_spec"

require "./model/associations/has_many/as_polymorphic_spec"
require "./model/associations/has_many/plain_spec"
require "./model/associations/has_many/through_spec"

require "./model/associations/has_one/as_polymorphic_spec"
require "./model/associations/has_one/plain_spec"
require "./model/associations/has_one/through_spec"

require "./model/repository/create_spec"
require "./model/repository/finders_spec"
require "./model/repository/update_spec"
require "./model/repository/delete_spec"

require "./controllers/controller_spec"

require "./model/repository/**"
