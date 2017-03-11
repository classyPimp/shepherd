class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Insert(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  @statements_args : Array(DB::Any)
  @statements_args = Array(DB::Any).new(10)

  @fields_to_insert_into : Array(String)
  @fields_to_insert_into = Array(String).new

  @owner_model : T

  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  def get_pg_placeholder_counter_incr : Int32
    @pg_placeholder_counter += 1
    return @pg_placeholder_counter
  end


  def initialize(@owner_model : T, @pg_placeholder_counter : Int32 = 0)
  end


  def set_fields_to_insert_into(*field_names : String) : Nil
    field_names.each do |field_name|
      @fields_to_insert_into << field_name
    end
  end

  def prepare_insert_into_field_names_statement : Nil
    @statements_io << "INSERT INTO " << T.table_name << ' '

    if @fields_to_insert_into.empty?
      @fields_to_insert_into = T.string_db_field_names_array_without_primary_key
    end
    fields_to_insert_into = @fields_to_insert_into.not_nil!

    size_flag = fields_to_insert_into.size
    @statements_io << " ("
    @statements_io << fields_to_insert_into[0]
    if size_flag > 1
      1..(size_flag - 1).times do |index|
        @statements_io << ", " << fields_to_insert_into[index + 1]
      end
    end
    @statements_io << ") "

    @statements_io << "VALUES ("
    @statements_io << "$" << get_pg_placeholder_counter_incr
    if size_flag > 1
      1..(size_flag-1).times do
        @statements_io << ", $" << get_pg_placeholder_counter_incr
      end
    end
    @statements_io << ')'

    @statements_io << " RETURNING id"
  end

  def get_statements_io : IO::Memory
    prepare_insert_into_field_names_statement
    return @statements_io
  end

  def get_statements_args : Array(DB::Any)
    unless @statements_args.empty?
      return @statements_args
    else
      @fields_to_insert_into.each do |field_name|
        @statements_args << @owner_model.get_property_by_name(field_name)
      end
      return @statements_args
    end
  end


end
