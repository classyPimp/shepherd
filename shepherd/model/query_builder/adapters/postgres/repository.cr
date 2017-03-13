require "./modules/finder_methods"

#this class acts as query builder
#How it works:
# it can be concluded that each sql query follows strict routine, or sequence of statements.
# this class has lazy initialized handler for each such statement.
# so only the one needed for specific query, are used.
# this class may seem as sort of god object, but, in this particular case, i can unfortunately see no other way of refactoring it.
# on the other hand, it reminds me the approach of react component, the path from start to end is visible and explicit, and statement parts
# act as sort of state.
# to avouid string allocs, query is maintened as io, as well as its parts in statment builders.
# each query is finalized with REST like methods (with google API recommendation falvor ):
# get #single record
# list #collection of records
# update #updates changes
# create #creates new record
# each that method, builds query depending on which statement builders where used and executes it,
# copying in stacklike fashion their parts and arguments
class Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(ConnectionGetterT, T)

  #methods exposed to user.
  include Shepherd::Model::QueryBuilder::Adapters::Postgres::Modules::FinderMethods(T)

  #used in inserting placeholders, PG specific
  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  @select_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T)
  @select_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T).new

  @from_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T)
  @from_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T).new

  @join_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T)?
  def get_or_init_join_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T)
    @join_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T).new
  end

  @where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)?
  def get_or_init_where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)
    @where_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T).new(@pg_placeholder_counter)
  end

  @order_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Order(T)?
  def get_or_init_order_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Order(T)
    @order_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Order(T).new
  end

  @limit_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Limit(T)?
  def get_or_init_limit_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Limit(T)
    @limit_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Limit(T).new
  end

  #eager loaders will 'procify' queries of dependent associations,
  #and each will be called when 'this' model will be queried and parsed
  #passing it's collection to eager loaders.
  #after that each eager loader will load dependent collection, and map them
  #to properites of this collection.
  #eager loaders can be chained, and nested
  @eager_loaders : Array(Shepherd::Model::EagerLoaderInterface)?
  def eager_loaders
    @eager_loaders ||= Array(Shepherd::Model::EagerLoaderInterface).new(5)
  end

  @insert_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Insert(T)?
  def get_or_init_insert_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Insert(T)
    @insert_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Insert(T).new(@owner_model.not_nil!, @pg_placeholder_counter)
  end

  @update_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Update(T)?
  def get_or_init_update_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Update(T)
    @update_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Update(T).new(@owner_model.not_nil!, @pg_placeholder_counter)
  end

  @delete_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Delete(T)?
  def get_or_init_delete_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Delete(T)
    @delete_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Delete(T).new(@owner_model.not_nil!)
  end

  #when query is finalized, statements from each builder part will be copied here,
  #in order defined by finalizing method. then this will be to_s'ed and passed to DB executor
  @final_query_accumulator : IO::Memory
  @final_query_accumulator = IO::Memory.new(2048)

  #when query is finalized statement args from each builder will be copied here,
  #and this will be passed to DB executor
  #in every query, any values will be 'placeholdered'
  @final_statement_args_accumulator : Array(DB::Any)
  @final_statement_args_accumulator = Array(DB::Any).new(10)

  #used in #update #create
  #becouse they need the prperties of it
  @owner_model : T?

  #blank initialize, for finder methods (#where and friends) which will be finalized with #get, #list
  def initialize
  end
  #overload for #update #create, assigning owner_model that will be updated/created, which will be finalized with #update #create
  def initialize(owner_model : T)
    @owner_model = owner_model
  end

  #makes query returns parsed collection of T
  #TODO: should use transaction
  def get : T?
    build_final_get_query
    query = @final_query_accumulator.to_s

    collection_to_return = ConnectionGetterT.get.query(query, @final_statement_args_accumulator) do |result_set|
      T.parse_db_result_set(result_set)
    end

    if @eager_loaders
      @eager_loaders.not_nil!.each do |eager_loader|
        eager_loader.as(T::EagerLoader).resolve(collection_to_return.as(Shepherd::Model::Collection(T)))
      end
    end

    return collection_to_return[0]?
  end

  def list
    build_final_get_query
    query = @final_query_accumulator.to_s

    collection_to_return = ConnectionGetterT.get.query(query, @final_statement_args_accumulator) do |result_set|
      T.parse_db_result_set(result_set)
    end

    if @eager_loaders
      @eager_loaders.not_nil!.each do |eager_loader|
        eager_loader.as(T::EagerLoader).resolve(collection_to_return.as(Shepherd::Model::Collection(T)))
      end
    end

    return collection_to_return
  end

  #creates returning id assigning it owner_model.id
  #TODO: should use transaction
  def create
    if @where_builder
      @pg_placeholder_counter = @where_builder.not_nil!.get_pg_placeholder_counter
    end
    get_or_init_insert_builder
    build_final_create_query
    returning_id = ConnectionGetterT.get.scalar(@final_query_accumulator.to_s, @final_statement_args_accumulator).as(Int32)
    @owner_model.not_nil!.id = returning_id
  end

  #overload to set fields that will be used as insert into (*field_names)
  #TODO: should use transaction
  def create(*field_names : String)
    if @where_builder
      @pg_placeholder_counter = @where_builder.not_nil!.get_pg_placeholder_counter
    end
    get_or_init_insert_builder
    @insert_builder.not_nil!.set_fields_to_insert_into(*field_names)
    build_final_create_query
    returning_id = ConnectionGetterT.get.scalar(@final_query_accumulator.to_s, @final_statement_args_accumulator).as(Int32)
    @owner_model.not_nil!.id = returning_id
  end

  #TODO: should user transaction
  def update
    get_or_init_update_builder
    @update_builder.not_nil!.prepare_insert_into_field_names_statement
    @pg_placeholder_counter = @update_builder.not_nil!.get_pg_placeholder_counter
    where(T, {"id", :eq, @owner_model.not_nil!.id})
    build_final_update_query
    ConnectionGetterT.get.exec(@final_query_accumulator.to_s, @final_statement_args_accumulator)
  end

  #TODO: should user transaction
  def update(*field_names : String)
    get_or_init_update_builder
    @update_builder.not_nil!.set_fields_to_update(*field_names)
    @update_builder.not_nil!.prepare_insert_into_field_names_statement
    @pg_placeholder_counter = @update_builder.not_nil!.get_pg_placeholder_counter
    where(T, {"id", :eq, @owner_model.not_nil!.id})
    build_final_update_query
    ConnectionGetterT.get.exec(@final_query_accumulator.to_s, @final_statement_args_accumulator)
  end

  def delete
    get_or_init_delete_builder
    @delete_builder.not_nil!.prepare_delete_statement
    where({"id", :eq, @owner_model.not_nil!.id})
    build_final_delete_query

    ConnectionGetterT.get.exec(@final_query_accumulator.to_s, @final_statement_args_accumulator)

  end

  #for debugging purposes, will print formed query, with formed statements
  def puts_query_and_args
    build_final_query
    p @final_query_accumulator.to_s
    p @final_statement_args_accumulator
  end
  #

  #build query to be executed on create
  def build_final_create_query : Nil
    if @where_builder
      add_where
      #TODO: handling pg counter should be more convenient, and not as ugly as  it is
      @pg_placeholder_counter = @where_builder.not_nil!.get_pg_placeholder_counter
    end
    add_insert
  end

  #build query to be executed on finders
  def build_final_get_query : Nil
    add_select
    add_from
    if @join_builder
      add_join
    end
    if @where_builder
      add_where
    end
    if @order_builder
      add_order
    end
    if @limit_builder
      add_limit
    end
  end

  def build_final_update_query : Nil
    add_update
    add_where
  end

  def build_final_delete_query
    add_delete
    add_where
  end

  #
  #TODO: should be DRYed a bit i guess. but on the other hand some may require a bit different handling
  #so #TODO think about refactoring
  def add_select : Nil
    copy_to_final_query_accumulator(@select_builder.get_statements_io)
  end

  def add_from : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@from_builder.get_statements_io)
  end

  def add_join : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@join_builder.not_nil!.get_statements_io)
  end
  #
  #
  def add_where : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@where_builder.not_nil!.get_statements_io)
    copy_to_final_statement_args_accumulator(@where_builder.not_nil!.get_statements_args)
  end

  def add_insert : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@insert_builder.not_nil!.get_statements_io)
    copy_to_final_statement_args_accumulator(@insert_builder.not_nil!.get_statements_args)
  end

  def add_update : Nil
    copy_to_final_query_accumulator(@update_builder.not_nil!.get_statements_io)
    copy_to_final_statement_args_accumulator(@update_builder.not_nil!.get_statements_args)
  end
  #
  #
  def add_order : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@order_builder.not_nil!.get_statements_io)
  end

  def add_limit : Nil
    add_space_char_to_final_query_accumulator
    copy_to_final_query_accumulator(@limit_builder.not_nil!.get_statements_io)
  end

  def add_delete
    copy_to_final_query_accumulator(@delete_builder.not_nil!.get_statements_io)
  end

  #to avoid String allocations query is built as Memory::IO, as well as all builders do
  #this will accept io from any builder, rewind it and copy to final query
  #then when all is done final query will be to_s'ed, and passed to DB executor
  private def copy_to_final_query_accumulator(source_io : IO::Memory) : Nil
    source_io.rewind
    buffer = uninitialized UInt8[512]
    if (read_bytes_length = source_io.read(buffer.to_slice)) > 0
      @final_query_accumulator.write( buffer.to_slice[0, read_bytes_length] )
    end

    source_io.close
  end

  #copies args from builders that will be passed to db's executor
  private def copy_to_final_statement_args_accumulator(source_array : Array(DB::Any)) : Nil
    source_array.each do |statement|
      @final_statement_args_accumulator << statement
    end
  end

  #TODO: should be hinted to compiler to be inlined i think
  private def add_space_char_to_final_query_accumulator : Nil
    @final_query_accumulator << ' '
  end

  #most statement builders require db table name to be passed,
  #but overloads exist to:
  #either pass it as string, infeered implicitly or inferred from given T
  #so this method serves for that.
  private def resolve_table_name(table_name : (String | Shepherd::Model::Base.class | Nil)) : String
    case table_name
    when Shepherd::Model::Base.class
      table_name = table_name.table_name
    when Nil
      table_name = T.table_name
    end
    return table_name
  end


end
