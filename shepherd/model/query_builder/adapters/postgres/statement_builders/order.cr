class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Order(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  def add_statement(table_name : String?, *args : String, direction : Symbol) : Nil
    @statements_io << "ORDER BY "

    size_flag = args.size
    @statements_io << table_name << '.' << args[size_flag - 1]
    if size_flag > 1
      1..(size_flag - 1).times do |index|
        @statements_io << ", " << table_name << '.' << args[index]
      end
    end

    insert_by(direction)
  end

  def insert_by(direction : Symbol) : Nil
    case direction
    when :asc
      @statements_io << " ASC"
    when :desc
      @statements_io << " DESC"
    end
  end

  def get_statements_io : IO::Memory
    @statements_io
  end

end
