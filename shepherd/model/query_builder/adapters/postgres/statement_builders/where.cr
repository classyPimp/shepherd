class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Where(T)

  @was_called : Bool
  @was_called = false

  @or_called : Bool
  @or_called = false

  def was_called : Bool
    @was_called
  end

  def mark_self_as_called : Nil
    @was_called = true
  end

  @statements_args : Array(DB::Any)
  @statements_args = Array(DB::Any).new(10)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  def initialize(@pg_placeholder_counter : Int32 = 0)
  end

  def get_current_placeholder_with_incr : Int32
    @pg_placeholder_counter += 1
    return @pg_placeholder_counter
  end

  def get_pg_placeholder_counter : Int32
    @pg_placeholder_counter
  end

  def add_statement(table_name : String?, *args : Tuple(String, Symbol, DB::Any)) : Nil

    insert_where_and_or_nil
    if table_name
      table_name = "#{table_name}."
    else
      table_name = nil
    end
    @statements_io << '('

    size_flag = args.size
    0..(size_flag - 1).times do |index|

      triplet = args[index]
      build_statement_depending_on_operator_kind_and_push_arg(table_name, triplet)

      @statements_io << " AND"

    end
    triplet = args[size_flag - 1]
    build_statement_depending_on_operator_kind_and_push_arg(table_name, triplet)

    @statements_io << " )"

    mark_self_as_called

  end

  def add_statement(table_name : String?, triplet : Tuple(String, Symbol, Array)) : Nil
    insert_where_and_or_nil
    if table_name
      table_name = "#{table_name}."
    else
      table_name = nil
    end

    field_name = triplet[0]
    operator = triplet[1]
    arguments = triplet[2]

    @statements_io << '('
    case operator
    when :in
      @statements_io << "#{table_name}#{field_name} in ("

      size_flag = arguments.size
      0..(size_flag - 1).times do |index|
        @statements_io << arguments[index]
        @statements_io << ", "
      end
      @statements_io << arguments[size_flag - 1]

      @statements_io << ')'
    else
      raise "unsupported operator #{operator} in where statement"
    end
    @statements_io << ')'

    mark_self_as_called
  end


  def raw_where(raw_statement : String, *args : DB::Any) : Nil
    insert_where_and_or_nil
    @statements_io << raw_statement
    args.each do |arg|
      @statements_args << arg
    end
  end


  def or_where(table_name : String, *args : Tuple(String, Symbol, DB::Any)) : Nil
    @or_called = true
    @statements_io << " OR "
    add_statement(table_name, *args)
    @or_called = false
  end

  def or_where(*args : Tuple(String, Symbol, DB::Any)) : Nil
    @or_called = true
    @statements_io << " OR "
    add_statement(nil, *args)
    @or_called = false
  end



  def build_statement_depending_on_operator_kind_and_push_arg(table_name : String?, triplet : Tuple(String, Symbol, DB::Any)) : Nil
    field_name = triplet[0]
    operator = triplet[1]
    operand = triplet[2]

    case operator
    when :eq
      build_equals(table_name, field_name)
    when :gt
      build_greater_than(table_name, field_name)
    when :lt
      build_less_than(table_name, field_name)
    else
      raise "unsupported operator: #{operator} in where statement"
    end

    @statements_args << operand
  end

  def build_equals(table_name : String?, field_name : String) : Nil
    insert_space_char_to_statements_io
    @statements_io << table_name  << field_name
    @statements_io << " = $#{get_current_placeholder_with_incr}"
  end


  def build_greater_than(table_name : String?, field_name : String) : Nil
    insert_space_char_to_statements_io
    @statements_io << table_name << field_name
    @statements_io << " > $#{get_current_placeholder_with_incr}"
  end

  def build_less_than(table_name : String?, field_name : String) : Nil
    insert_space_char_to_statements_io
    @statements_io << table_name << field_name
    @statements_io << " < $#{get_current_placeholder_with_incr}"
  end

  def insert_space_char_to_statements_io : Nil
    @statements_io << ' '
  end

  def get_statements_io : IO::Memory
    return @statements_io
  end

  def get_statements_args : Array(DB::Any)
    return @statements_args
  end

  def insert_where_and_or_nil : Nil
    if @or_called
      nil
    elsif @was_called
      @statements_io << " AND "
    else
      @statements_io << "WHERE "
    end
  end

end
