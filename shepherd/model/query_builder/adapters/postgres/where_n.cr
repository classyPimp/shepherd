# require "../../interfaces/where"
#
# class Shepherd::Model::QueryBuilder::Adapters::Postgres::WhereN(ConnectionGetterT, T)
#
#   include Shepherd::Model::QueryBuilder::Interfaces::Where
#
#   @select_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select?
#
#   def get_or_init_select_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T)
#     @select_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T).new
#   end
#
#   @where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)?
#
#   def get_or_init_where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)
#     @where_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T).new
#   end
#
#   @from_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T)?
#
#   def get_or_init_from_builder
#     @from_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T).new
#   end
#
#   @query_accumulator : IO::Memory
#   @query_accumulator = IO::Memory.new(2048)
#
#   @read_buffer_proxy = uninitialized UInt8[512]
#
#   @final_statements : Array(DB::Any)
#   @final_statements = Array(DB::Any).new(10)
#
#   @pg_placeholder_counter : Int32
#   @pg_placeholder_counter = 0
#
#   def get_current_placeholder : Int32
#     @pg_placeholder_counter += 1
#     return @pg_placeholder_counter
#   end
#
#   def select(prefix : (String), *field_names : String) : self
#     get_or_init_select_builder.add_statement(prefix: prefix, field_names: field_names)
#     self
#   end
#
#   def select(*field_names, prefix : Bool)
#     get_or_init_select_builder.
#     self
#   end
#
#
#
#   def get
#
#   end
#
#
# end
