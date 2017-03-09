require "../../interfaces/where"

class Shepherd::Model::QueryBuilder::Adapters::Postgres::WhereN(ConnectionGetterT, T)

  include Shepherd::Model::QueryBuilder::Interfaces::Where


  @select_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T)
  @select_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T).new


  @from_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T)
  @from_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T).new

  @where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)?
  def get_or_init_where_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)
    @where_builder ||= Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T).new
  end

  @join_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T)?
  def get_or_init_join_builder : Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T)
    @join_builder = Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T).new
  end

  @eager_loaders : Array(Shepherd::Model::EagerLoaderInterface)?
  def eager_loaders
    @eager_loaders ||= Array(Shepherd::Model::EagerLoaderInterface).new(5)
  end

  @final_query_accumulator : IO::Memory
  @final_query_accumulator = IO::Memory.new(2048)

  @statement_read_buffer_proxy = uninitialized UInt8[512]

  @final_statement_args : Array(DB::Any)
  @final_statement_args = Array(DB::Any).new(10)

  #select and overloads
  def select(*field_names : String) : self
    @select_builder.add_statement(*field_names)
    self
  end

  def select(table_name : (String | Shepherd::Model::Base.class), *field_names : String) : self
    table_name = resolve_table_name(table_name)
    @select_builder.add_statement(table_name, *field_names)
    self
  end
  #/select and overloads

  #from and overloads
  def from(table_name : (String | Shepherd::Model::Base.class)) : self
    table_name = resolve_table_name(table_name)
    @from_builder.add_statement(table_name)
    self
  end

  #/from and overloads
  #
  #where and overloads
  def where(table_name : (String | Shepherd::Model::Base.class), *args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(table_name)
    get_or_init_where_builder.add_statement(table_name, *args)
    self
  end

  def where(*args : Tuple(String, Symbol, DB::Any)) : self
    table_name = T.table_name
    get_or_init_where_builder.add_statement(table_name, *args)
    self
  end

  def where(*args : Tuple(String, Symbol, DB::Any), no_prefix : Bool) : self
    table_name = resolve_table_name(T)
    get_or_init_where_builder.add_statement(table_name, *args)
    self
  end

  #Overload for handling IN statement (for future any other that supplies array)
  def where(table_name : (String | Shepherd::Model::Base.class), triplet : Tuple(String, Symbol, Array))

    table_name = resolve_table_name(table_name)

    get_or_init_where_builder.add_statement(table_name, triplet)

    self

  end

  def where(triplet : Tuple(String, Symbol, Array))
    table_name = resolve_table_name(T)
    get_or_init_where_builder.add_statement(table_name, triplet)

    self

  end
  #/where and overloads
  #or_where and overloads
  def or_where(table_name : (String | Shepherd::Model::Base.class), *args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(table_name)
    get_or_init_where_builder.or_where(table_name, *args)
    self
  end

  def or_where(*args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(T)
    get_or_init_where_builder.or_where(table_name, *args)
    self
  end
  #/or_where and overloads
  #join and overloads
  #inner_join adn overloads
  def inner_join(&block) : self
    join_builder = yield T::JoinBuilder.new(Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner)
    get_or_init_join_builder.feed(join_builder.get_statements)
    self
  end
  #/inner_join and overloads
  #/join and overloads
  #
  #eager_load and overloads
  def eager_load(&block : T::EagerLoader -> Nil)

    eager_loader = T::EagerLoader.new
    eager_loaders << eager_loader

    yield eager_loader

    self
  end
  #
  #
  #
  def get : Shepherd::Model::Collection(T)
    build_final_query
    query = @final_query_accumulator.to_s

    collection_to_return = ConnectionGetterT.get.query(query, @final_statement_args) do |result_set|
      T.parse_db_result_set(result_set)
    end

    if @eager_loaders
      @eager_loaders.not_nil!.each do |eager_loader|
        eager_loader.as(T::EagerLoader).resolve(collection_to_return.as(Shepherd::Model::Collection(T)))
      end
    end

    return collection_to_return
  end

  def puts_query_and_args
    build_final_query
    p @final_query_accumulator.to_s
    p @final_statement_args
  end
  #
  def build_final_query : Nil
    add_select
    add_space_char_to_final_query_accumulator
    add_from
    if @join_builder
      add_space_char_to_final_query_accumulator
      add_join
    end
    if @where_builder
      add_space_char_to_final_query_accumulator
      add_where
    end
  end
  #
  def add_select : Nil
    copy_to_final_query_accumulator(@select_builder.get_statements_io)
  end


  def add_from : Nil
    copy_to_final_query_accumulator(@from_builder.get_statements_io)
  end

  def add_join : Nil
    copy_to_final_query_accumulator(@join_builder.not_nil!.get_statements_io)
  end
  #
  #
  def add_where : Nil
    copy_to_final_query_accumulator(@where_builder.not_nil!.get_statements_io)
    copy_to_final_statement_args(@where_builder.not_nil!.get_statements_args)
  end
  #
  #
  def copy_to_final_query_accumulator(source_io : IO::Memory) : Nil
    source_io.rewind

    if (read_bytes_length = source_io.read(@statement_read_buffer_proxy.to_slice)) > 0
      @final_query_accumulator.write( @statement_read_buffer_proxy.to_slice[0, read_bytes_length] )
    end

    source_io.close
  end

  def copy_to_final_statement_args(source_array : Array(DB::Any)) : Nil
    source_array.each do |statement|
      @final_statement_args << statement
    end
  end

  private def add_space_char_to_final_query_accumulator : Nil
    @final_query_accumulator << ' '
  end


  private def resolve_table_name(table_name : (String | Shepherd::Model::Base.class)) : String
    case table_name
    when Shepherd::Model::Base.class
      table_name = table_name.table_name
    end
    return table_name
  end


end
