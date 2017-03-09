class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::From(T)

  @was_called : Bool
  @was_called = false

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(128)

  def was_called : Bool
    @was_called
  end

  def mark_self_as_called
    @was_called = true
  end


  def add_statement(table_name : String) : Nil
    @statements_io << "FROM #{table_name}"
    mark_self_as_called
  end

  def get_statements_io : IO::Memory
    unless was_called
      build_default_statements
    end
    return @statements_io
  end

  def build_default_statements : IO::Memory
    @statements_io << "FROM #{T.table_name}"
  end

end
