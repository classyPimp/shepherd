require "./modules/finder_methods"
class Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(ConnectionGetterT, T)

  include Shepherd::Model::QueryBuilder::Adapters::Postgres::Modules::FinderMethods(T)

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

  @final_query_accumulator : IO::Memory
  @final_query_accumulator = IO::Memory.new(2048)

  @final_statement_args_accumulator : Array(DB::Any)
  @final_statement_args_accumulator = Array(DB::Any).new(10)

  #used in update
  @owner_model : T?

  #blank initialize, for finder method
  def initialize
  end
  #for #update #create
  def initialize(owner_model : T)
    @owner_model = owner_model
  end

  #makes query returns parsed collection
  def get : Shepherd::Model::Collection(T)
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

  def update
    get_or_init_update_builder
    @update_builder.not_nil!.prepare_insert_into_field_names_statement
    @pg_placeholder_counter = @update_builder.not_nil!.get_pg_placeholder_counter
    where(T, {"id", :eq, @owner_model.not_nil!.id})
    build_final_update_query
    ConnectionGetterT.get.exec(@final_query_accumulator.to_s, @final_statement_args_accumulator)
  end

  def update(*field_names : String)
    get_or_init_update_builder
    @update_builder.not_nil!.set_fields_to_update(*field_names)
    @update_builder.not_nil!.prepare_insert_into_field_names_statement
    @pg_placeholder_counter = @update_builder.not_nil!.get_pg_placeholder_counter
    where(T, {"id", :eq, @owner_model.not_nil!.id})
    build_final_update_query
    ConnectionGetterT.get.exec(@final_query_accumulator.to_s, @final_statement_args_accumulator)
  end


  def puts_query_and_args
    build_final_query
    p @final_query_accumulator.to_s
    p @final_statement_args_accumulator
  end
  #

  def build_final_create_query : Nil
    if @where_builder
      add_where
      @pg_placeholder_counter = @where_builder.not_nil!.get_pg_placeholder_counter
    end
    add_insert
  end


  def build_final_get_query : Nil
    add_select
    add_space_char_to_final_query_accumulator
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

  #
  def add_select : Nil
    copy_to_final_query_accumulator(@select_builder.get_statements_io)
  end


  def add_from : Nil
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


  private def copy_to_final_query_accumulator(source_io : IO::Memory) : Nil
    source_io.rewind
    buffer = uninitialized UInt8[512]
    if (read_bytes_length = source_io.read(buffer.to_slice)) > 0
      @final_query_accumulator.write( buffer.to_slice[0, read_bytes_length] )
    end

    source_io.close
  end

  private def copy_to_final_statement_args_accumulator(source_array : Array(DB::Any)) : Nil
    source_array.each do |statement|
      @final_statement_args_accumulator << statement
    end
  end

  private def add_space_char_to_final_query_accumulator : Nil
    @final_query_accumulator << ' '
  end


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
