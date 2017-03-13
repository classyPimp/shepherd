class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Delete(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  @owner_model : T

  def initialize(@owner_model : T)
  end

  def prepare_delete_statement : Nil
    @statements_io << "DELETE FROM " << T.table_name
  end

  def get_statements_io : IO::Memory
    @statements_io
  end

end
