require "db"
require "pg"

DATABASE_CONNECTION = DB.open Shepherd::Configuration::Database::INSTANCE.get_connection_address
