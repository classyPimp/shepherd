require "../../interfaces/where"

class Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(T)

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

  @where_part_string_builder : String::Builder
  @where_part_string_builder = String::Builder.new

  @select_part_string_builder : String::Builder
  @select_part_string_builder = String::Builder.new

  @from_part_string_builder : String::Builder
  @from_part_string_builder = String::Builder.new

  @limit_clause : String?

  def initialize
    @from_part_string_builder << " FROM"
    @select_part_string_builder << "SELECT"
  end

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
    self
  end

  def where(prefix, *args)

    insert_where_and_or_nil
    @where_called = true

    @where_part_string_builder << '('
    args.each do |triple|
      case triple[1]
      when :eq
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triple[0] << " = $#{place_holder} "
      when :in
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triple[0] << " in ($#{place_holder}) "
      end
      @where_part_string_builder << "AND"

      @where_statement_args << triple[2]

    end
    @where_part_string_builder.back(4)
    @where_part_string_builder << ") "

    self

  end

  def or(prefix, *args)
    @or_called = true
    @where_part_string_builder << "OR "
    where(prefix, *args)
    @or_called = false
    self
  end

  def limit(value : Int32)
    @limit_clause = " LIMIT #{value}"
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
      query << finalize_where_part
      if @limit_clause
        query << @limit_clause
      end
    end
    resulting_query.to_s
  end

  def execute
    DATABASE_CONNECTION.query(build_query, @statement_args) do |result_set|
      T.parse_db_result_set(result_set)
    end
  end

  def to_sql_string
    build_query
  end

  def puts_sql_query_and_statements
    puts build_query
    puts @statement_args
  end


  def place_holder
    @pg_placeholder_counter += 1
    @pg_placeholder_counter
  end


  def default_select
    " *"
  end


  def default_from
    T.table_name.as(String)
  end


  def finalize_select_part
    unless @select_called
      @select_part_string_builder << default_select
    end
    @select_part_string_builder.to_s
  end


  def finalize_from_part
    unless @from_called
      @from_part_string_builder << " #{self.default_from} "
    end
    @from_part_string_builder.to_s
  end

  def finalize_where_part
    @where_statement_args.each do |arg|
      @statement_args << arg
    end
    @where_part_string_builder.to_s
  end

end
