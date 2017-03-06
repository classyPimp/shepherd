require "../../interfaces/where"
#works like waterfall.
#will build statements as you call them
class Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(ConnectionGetterT, T)
  #TODO SHOULD CLOSE STRINGBUILDERS OF UNCALLED PARTS ON FINALIZATION OR IN EXECUTE
  #TODO WRITE INTERFACE WITH ALL NECESSARY ABSTRACT METHODS
  include Shepherd::Model::QueryBuilder::Interfaces::Where

  #these will be passed as args with finaly built query
  @statement_args : Array(DB::Any)
  @statement_args = Array(DB::Any).new(20)

  #when where statements will be assembled, these would go
  #to @statement_args
  @where_statement_args : Array(DB::Any)
  @where_statement_args = Array(DB::Any).new(20)

  #user in #place_holder, refer there
  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  #acts as flag
  @where_called : Bool
  @where_called = false

  #acts as flag
  @or_called : Bool
  @or_called = false

  #acts as flag
  @select_called : Bool
  @select_called = false

  #acts as flag
  @from_called : Bool
  @from_called = false

  #TODO REFACTOR WITH LAZY INITIALIZED GETTERS
  #TODO if where not used, streams should be closed
  @where_part_string_builder : String::Builder
  @where_part_string_builder = String::Builder.new

  @select_part_string_builder : String::Builder
  @select_part_string_builder = String::Builder.new

  @from_part_string_builder : String::Builder
  @from_part_string_builder = String::Builder.new

  #acts as flag
  @join_called : Bool
  @join_called = false

  @join_part_string_builder : String::Builder
  @join_part_string_builder = String::Builder.new

  @order_clause : String?

  @limit_clause : String?

  @eager_load_called : Bool
  @eager_load_called = false

  #eager loaders which all will be called, as soon as final query executed
  #passing them the parse collection of T
  @eager_loaders : Array(Shepherd::Model::EagerLoaderInterface)?
  #getter
  def eager_loaders
    @eager_loaders ||= Array(Shepherd::Model::EagerLoaderInterface).new(5)
  end

  def initialize
    @from_part_string_builder << " FROM"
    @select_part_string_builder << "SELECT"
  end


  #TODO: REFACTOR prefix should be model class , and  prefix should be fetched from .table_name
  #TODO: write overload that does not prefix, for passing e.g. select("aliasedusers.foo")
  def select(prefix : (String | Shepherd::Model::Base.class | Nil), *args : String)

    prefix = resolve_table_name_prefix(prefix)

    @select_called = true

    @select_part_string_builder << ' '
    args.each do |arg|
      @select_part_string_builder << prefix << '.' << arg << ", "
    end
    @select_part_string_builder.back(2)
    @select_part_string_builder << ' '

    self

  end

  #simply will use passed value in select statement when finalized
  def from(table_name)
    @from_called = true
    @from_part_string_builder << table_name << ' '
    self
  end


  #where builder
  def where(prefix : (String | Shepherd::Model::Base.class | Nil), *args : Tuple(String, Symbol, DB::Any))

    prefix = resolve_table_name_prefix(prefix)

    insert_where_and_or_nil

    @where_called = true

    @where_part_string_builder << '('
    args.each do |triplet|
      case triplet[1]
      when :eq
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triplet[0] << " = $#{place_holder} "
      when :gt
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triplet[0] << " > $#{place_holder} "
      when :lt
        @where_part_string_builder << ' ' << prefix << '.'
        @where_part_string_builder << triplet[0] << " < $#{place_holder} "
      else
        raise "unsupported operator: #{triplet[1]} in where statement"
      end
      @where_part_string_builder << "AND"

      @where_statement_args << triplet[2]

    end
    #if several wheres called moves pointer voiding last AND
    @where_part_string_builder.back(4)
    @where_part_string_builder << ") "

    self

  end

  #where overload that sets default prefix for table_name
  def where(*args : Tuple(String, Symbol, DB::Any))
    self.where(nil, *args)
  end

  #resolves table name prefix used in methods that add to statements
  private def resolve_table_name_prefix(prefix : (String | Shepherd::Model::Base.class | Nil)) : String?
    case prefix
    when String
      nil
    when Shepherd::Model::Base.class
      prefix = prefix.table_name
    when nil
      prefix = T.table_name
    end
    prefix
  end


  #Overload for handling IN statement (for future any other that supplies array)
  def where(prefix : (String | Shepherd::Model::Base.class | Nil), triplet : Tuple(String, Symbol, Array))

    prefix = resolve_table_name_prefix(prefix)

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

  #overload that infers the tablename (prefix) without providing it
  #to call where (IN)
  def where(triplet : Tuple(String, Symbol, Array))
    self.where(nil, triplet)
  end

  #TODO: should scan for ? place_holders and insert next in sequence
  #currently user has to provide himself
  def where(raw_query : String, *args : DB::Any)
    insert_where_and_or_nil
    @where_called = true
    @where_part_string_builder << ' ' << raw_query << ' '
    args.each do |arg|
      @where_statement_args << arg
    end
    self
  end

  # def raw(*, inner_join : String, *args : DB::Any )
  #
  # end


  #TODO: REFACTOR prefix should be model class , and  prefix should be fetched from .table_name
  def or(prefix, *args)
    @or_called = true
    @where_part_string_builder << "OR "
    where(prefix, *args)
    @or_called = false
    self
  end

  #overload to infer prefix automaticvally
  def or(*args)
    or(nil, *args)
  end

  #builds limit statement
  #several calls will overwrite
  def limit(value : Int32)
    @limit_clause = " LIMIT #{value}"
    self
  end


  def order_by(column_name : String, type : Symbol, *, prefix : String = T.table_name)
    @order_clause = String.build do |str|
      str << " ORDER BY #{T.table_name}.#{column_name} "
      case type
      when :desc
        str << "DESC "
      when :asc
        str << "ASC "
      else
        raise "unknown argument in order clause"
      end
    end
    self
  end
  #decides depending on what was called
  #wherer to insert WHERE || nil || AND
  private def insert_where_and_or_nil : Nil
    if !@where_called
      @where_part_string_builder << "WHERE "
    elsif @or_called
      nil
    else
      @where_part_string_builder << "AND "
    end
  end

  #finalizing methods builds final query that'll be executed
  private def build_query
    resulting_query = String.build do |query|
      query << finalize_select_part
      query << finalize_from_part
      if @join_called
        query << finalize_join_part
      end
      query << finalize_where_part
      if @order_clause
        query << @order_clause
      end
      if @limit_clause
        query << @limit_clause
      end
    end
    resulting_query.to_s
  end

  #calls the finaling statement builder method
  #and executes it against DB,
  #calls the result parser
  #returns the Collection(T)
  #TODO: think maybe #get instead of execute is better idea (at least for Where)
  def execute : Shepherd::Model::Collection(T)
    query = build_query
    #TODO: Should print to logger when logger will be implemented
    # p query
    # p @statement_args
    collection_to_return = ConnectionGetterT.get.query(query, @statement_args) do |result_set|
      T.parse_db_result_set(result_set)
    end

    #calls the eager loaders, loading models assigning them to
    #ones in upper parsed collection
    if @eager_load_called
      eager_loaders.each do |eager_loader|
        eager_loader.as(T::EagerLoader).resolve(collection_to_return.as(Shepherd::Model::Collection(T)))
      end
    end

    return collection_to_return

  end

  #used for devuggin purposes
  def to_sql_string
    build_query
  end

  #used for debugging purposes
  def puts_sql_query_and_statements : Nil
    puts build_query
    puts @statement_args
  end

  #used for PG only, keeps track of place_holders
  #resembling to appropriate index in statement args
  private def place_holder : Int32
    @pg_placeholder_counter += 1
    @pg_placeholder_counter
  end

  #if no select called this will be passed
  #is used outside so public (in join builders I guess)
  def default_select : String
    " #{T.table_name}.*"
  end

  #if no from called this will passed
  def default_from : String
    T.table_name#.as(String)
  end

  #name says it all
  private def finalize_select_part : String
    unless @select_called
      @select_part_string_builder << default_select
    end
    @select_part_string_builder.to_s
  end

  #name says it all
  private def finalize_from_part : String
    unless @from_called
      @from_part_string_builder << " #{self.default_from} "
    end
    @from_part_string_builder.to_s
  end

  #name says it all
  private def finalize_join_part : String
    @join_part_string_builder.to_s
  end

  #name says it all
  private def finalize_where_part : String
    @where_statement_args.each do |arg|
      @statement_args << arg
    end
    @where_part_string_builder.to_s
  end

  #joins the associations that where defined.
  #yilded join builders can chain their join builders and etc.
  def inner_join(&block) : self
    @join_called = true
    join_builder = yield T::JoinBuilder.new(Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner)
    statements = join_builder.get_statements

    statements.each do |statement|
      case statement[:join_type]
      when Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner
        @join_part_string_builder << " INNER JOIN "
      end

      table_name_or_alias = statement[:alias_as] ? statement[:alias_as] : statement[:class_to_join].table_name.as(String)

      @join_part_string_builder << "#{statement[:class_to_join].table_name.as(String)} #{(statement[:alias_as] ? statement[:alias_as] : nil)} on #{statement[:parent].table_name.as(String)}.#{statement[:parent_column]} = #{table_name_or_alias}.#{statement[:class_to_join_column]} "
      if statement[:extra_join_criteria]
        @join_part_string_builder << statement[:extra_join_criteria]
      end
      #add_extra_join_if_any(statement[:extra_join])
    end

    self
  end

  #not used started to implement but refused to continue
  #if join builder returns statement with extra_join_criteria, this method adds this criterias to @join_builder
  #now the raw statement is passed which can conflict between adapters
  def add_extra_join_if_any(extra_join : Array(Tuple(Symbol, String, Symbol, DB::Any))?) : Nil

    if extra_join

      extra_join.each do |options|
        type = options[0]
        left_operand = options[1]
        operator = options[2]
        right_operand = options[3]

        case type
        when :and
          @join_part_string_builder << " AND "
          @join_part_string_builder << left_operand
          case operand
          when :eq
            @join_part_string_builder << " = "
          end
          @join_part_string_builder << right_operand
        end

      end

    end

  end

  def raw_join(raw_join_statement : String)
    @join_called = true
    @join_part_string_builder << raw_join_statement
    self
  end
  #loads the selected
  def eager_load(&block : T::EagerLoader -> Nil)
    @eager_load_called = true

    eager_loader = T::EagerLoader.new
    eager_loaders << eager_loader

    yield eager_loader

    self
  end


end
