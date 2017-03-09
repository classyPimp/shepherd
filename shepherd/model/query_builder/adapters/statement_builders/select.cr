class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Select(T)

  @was_called : Bool
  @was_called = false

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  def was_called : Bool
    @was_called
  end

  def mark_self_as_called : Nil
    @was_called = true
  end

  #add_statement and overloads
  def add_statement(table_name : String, *field_names : String) : Nil
    if @was_called
      @statements_io << ", "
    else
      @statements_io << "SELECT "
    end

    size_flag = field_names.size
    0..(size_flag - 1).times do |index|
      @statements_io << table_name << '.' << field_names[index] << ", "
    end
    @statements_io << table_name << '.' << field_names[size_flag - 1]

    mark_self_as_called
  end

  def add_statement(*field_names : String)
    if @was_called
      @statements_io << ", "
    else
      @statements_io << "SELECT "
    end

    size_flag = field_names.size
    0..(size_flag - 1).times do |index|
      @statements_io << field_names[index] << ", "
    end
    @statements_io << field_names[size_flag - 1]

    mark_self_as_called

  end
  #/add_statement and overloads


  def get_statements_io : IO::Memory
    unless was_called
      build_default_statements
    end
    return @statements_io
  end

  def build_default_statements : Nil
    @statements_io << "SELECT #{T.table_name}.*"
  end

end
