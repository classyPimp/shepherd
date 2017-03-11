class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Update(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  @statements_args : Array(DB::Any)
  @statements_args = Array(DB::Any).new(10)

  @fields_to_update : Array(String)
  @fields_to_update = Array(String).new

  @owner_model : T

  @pg_placeholder_counter : Int32
  @pg_placeholder_counter = 0

  def get_pg_placeholder_counter_incr : Int32
    @pg_placeholder_counter += 1
    return @pg_placeholder_counter
  end

  def get_pg_placeholder_counter : Int32
    return @pg_placeholder_counter
  end

  def set_fields_to_update(*fields : String) : Nil
    fields.each do |field_name|
      @fields_to_update << field_name
    end
  end

  def initialize(@owner_model : T, @pg_placeholder_counter : Int32 = 0)
  end

  def prepare_insert_into_field_names_statement : Nil
    @statements_io << "UPDATE " << T.table_name << ' '

    if @fields_to_update.empty?
      @fields_to_update = T.string_db_field_names_array_without_primary_key
    end
    fields_to_update = @fields_to_update.not_nil!

    @statements_io << "SET "
    size_flag = fields_to_update.size

    @statements_io << fields_to_update[0] << " =" << " $" << get_pg_placeholder_counter_incr
    if size_flag > 1
      1..(size_flag - 1).times do |index|
        @statements_io << ", " << fields_to_update[index + 1] << " =" << " $" << get_pg_placeholder_counter_incr
      end
    end

  end

  def get_statements_io : IO::Memory
    return @statements_io
  end

  def get_statements_args : Array(DB::Any)
    unless @statements_args.empty?
      return @statements_args
    else
      @fields_to_update.each do |field_name|
        @statements_args << @owner_model.get_property_by_name(field_name)
      end
      return @statements_args
    end
  end

end
