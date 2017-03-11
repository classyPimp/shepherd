class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Limit(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(4)

  def add_statement(limit_amount : Int32)
    @statements_io << "LIMIT " << limit_amount
  end

  def get_statements_io : IO::Memory
    return @statements_io
  end

end
