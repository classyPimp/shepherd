require "../../interfaces/where"

class Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(ConnectionGetterT, T)
  #TODO SHOULD CLOSE STRINGBUILDERS OF UNCALLED PARTS ON FINALIZATION OR IN EXECUTE
  #TODO WRITE INTERFACE WITH ALL NECESSARY ABSTRACT METHODS
  include Shepherd::Model::QueryBuilder::Interfaces::Where

  @statement_args : Array(DB::Any)
  @statement_args = Array(DB::Any).new(20)

  @where_statement_args : Array(DB::Any)
  @where_statement_args = Array(DB::Any).new(20)

  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  @where_called : Bool
  @where_called = false

  @or_called : Bool
  @or_called = false

  @select_called : Bool
  @select_called = false

  @from_called : Bool
  @from_called = false

  #TODO REFACTOR WITH LAZY INITIALIZED GETTERS
  @where_part_string_builder : String::Builder
  @where_part_string_builder = String::Builder.new

  @select_part_string_builder : String::Builder
  @select_part_string_builder = String::Builder.new

  @from_part_string_builder : String::Builder
  @from_part_string_builder = String::Builder.new

  @join_called : Bool
  @join_called = false

  @join_part_string_builder : String::Builder
  @join_part_string_builder = String::Builder.new

  @limit_clause : String?

  @eager_load_called : Bool
  @eager_load_called = false

  @eager_loaders : Array(Shepherd::Model::EagerLoaderInterface)?
  def eager_loaders
    @eager_loaders ||= Array(Shepherd::Model::EagerLoaderInterface).new(10)
  end

  def initialize
    @from_part_string_builder << " FROM"
    @select_part_string_builder << "SELECT"
  end

  #TODO: REFACTOR prefix should be model class , and  prefix should be fetched from .table_name
  def select(prefix : String, *args : String)
    @select_called = true

    @select_part_string_builder << ' '
    args.each do |arg|
      @select_part_string_builder << prefix << '.' << arg << ", "
    end
    @select_part_string_builder.back(2)
    @select_part_string_builder << ' '

    self
  end


  def from(table_name)
    @from_called = true
    @from_part_string_builder << table_name << ' '

    self
  end

  #Tuple(String, Symbol, DB::Any)
  def where(raw_query : String, *args : DB::Any)
    @where_part_string_builder << raw_query << ' '
    #TODO: should push args to where args
    self
  end

  #TODO: REFACTOR prefix should be model class , and  prefix should be fetched from .table_name
  def where(prefix : (String | Shepherd::Model::Base.class | Nil), *args : Tuple(String, Symbol, DB::Any))

    case prefix
    when String
      nil
    when Shepherd::Model::Base.class
      prefix = prefix.table_name
    when nil
      prefix = T.table_name
    end

    insert_where_and_or_nil

    @where_called = true

    @where_part_string_builder << '('
    args.each do |triple|
      case triple[1]
      when :eq
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triple[0] << " = $#{place_holder} "
      # when :in
      #   @where_part_string_builder << ' ' << prefix << '.'
      #   @where_part_string_builder << triple[0] << " in ($#{place_holder}) "
      end
      @where_part_string_builder << "AND"

      @where_statement_args << triple[2]

    end
    @where_part_string_builder.back(4)
    @where_part_string_builder << ") "

    self

  end
  #Overload for handling IN statement (for future any other that supplies array)
  def where(prefix, triplet : Tuple(String, Symbol, Array))
    case prefix
    when String
      nil
    when Shepherd::Model::Base.class
      prefix = prefix.table_name
    when nil
      prefix = T.table_name
    end

    insert_where_and_or_nil
    @where_called = true

    @where_part_string_builder << '('
    case triplet[1]
    when :in
      @where_part_string_builder << "#{prefix}.#{triplet[0]} in ("

      triplet[2].each do |val|
        @where_part_string_builder << val
        @where_part_string_builder << ", "
      end

      @where_part_string_builder.back(2)
      @where_part_string_builder << ")"
    else
      raise "unsupported operator #{triplet[1]} in where statement"
    end
    @where_part_string_builder << ") "

    self

  end

  #TODO: REFACTOR prefix should be model class , and  prefix should be fetched from .table_name
  def or(prefix, *args)
    @or_called = true
    @where_part_string_builder << "OR "
    where(prefix, *args)
    @or_called = false
    self
  end


  def limit(value : Int32)
    @limit_clause = " LIMIT #{value}"
    self
  end


  def insert_where_and_or_nil : Nil
    if !@where_called
      @where_part_string_builder << "WHERE "
    elsif @or_called
      nil
    else
      @where_part_string_builder << "AND "
    end
  end


  def build_query
    resulting_query = String.build do |query|
      query << finalize_select_part
      query << finalize_from_part
      if @join_called
        query << finalize_join_part
      end
      query << finalize_where_part
      if @limit_clause
        query << @limit_clause
      end
    end
    resulting_query.to_s
  end

  def execute

    query = build_query
    #TODO: Should print to logger when logger will be implemented
    p query
    p @statement_args

    collection_to_return = ConnectionGetterT.get.query(query, @statement_args) do |result_set|
      T.parse_db_result_set(result_set)
    end

    if @eager_load_called
      eager_loaders.each do |eager_loader|
        eager_loader.as(T::EagerLoader).resolve(collection_to_return.as(Shepherd::Model::Collection(T)))
      end
    end

    collection_to_return

  end

  def to_sql_string
    build_query
  end

  def puts_sql_query_and_statements : Nil
    puts build_query
    puts @statement_args
  end


  def place_holder : Int32
    @pg_placeholder_counter += 1
    @pg_placeholder_counter
  end


  def default_select : String
    " *"
  end


  def default_from : String
    T.table_name#.as(String)
  end


  def finalize_select_part : String
    unless @select_called
      @select_part_string_builder << default_select
    end
    @select_part_string_builder.to_s
  end


  def finalize_from_part : String
    unless @from_called
      @from_part_string_builder << " #{self.default_from} "
    end
    @from_part_string_builder.to_s
  end

  def finalize_join_part : String
    @join_part_string_builder.to_s
  end

  def finalize_where_part : String
    @where_statement_args.each do |arg|
      @statement_args << arg
    end
    @where_part_string_builder.to_s
  end

  def inner_join(&block) : self
    @join_called = true
    join_builder = yield T::JoinBuilder.new(Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner)
    statements = join_builder.get_statements
    statements.each do |statement|
      case statement[:join_type]
      when Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner
        @join_part_string_builder << " INNER JOIN "
      end
      @join_part_string_builder << "#{statement[:class_to_join].table_name.as(String)} on #{statement[:parent].table_name.as(String)}.#{statement[:parent_column]} = #{statement[:class_to_join].table_name.as(String)}.#{statement[:class_to_join_column]} "
    end
    self
  end

  def eager_load(&block : T::EagerLoader -> Nil)
    @eager_load_called = true

    eager_loader = T::EagerLoader.new
    eager_loaders << eager_loader

    yield eager_loader

    self
  end


end
