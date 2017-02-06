require "../interfaces/create"

class Shepherd::Model::QueryBuilder::Create::Postgres(T)

  include Shepherd::Model::QueryBuilder::Interfaces::Create

  @owner_model : T
  @insert_into_column_names : Array(String)


  @query_to_execute : String?
  @returning_id : Bool
  @values_to_insert : Array(::DB::Any)?

  @returning_id = true


  def initialize(@owner_model : T)
    @insert_into_column_names = @owner_model.class.string_db_field_names_array_without_primary_key
  end


  def initialize(@owner_model : T, *field_names : String)
    @insert_into_column_names = field_names
  end



  def execute

    @query_to_execute = build_query
    @values_to_insert = get_values_to_insert
    p @query_to_execute
    p @values_to_insert
    returning_id = DATABASE_CONNECTION.scalar(@query_to_execute.not_nil!, @values_to_insert).as(Int32)

    if returning_id
      @owner_model.id = returning_id
    end
  end


  def get_sql_query_string : String
    build_query
  end

  def execute(*, with_transaction : Bool)

    @query_to_execute = build_query
    @values_to_insert = get_values_to_insert

    DATABASE_CONNECTION.transaction do |transaction|

      returning_id = transaction.connection.scalar(@query_to_execute.as(String), @values_to_insert).as(Int32)

    end

    returning_id

  end


  def get_values_to_insert : Array(::DB::Any)
    @insert_into_column_names.map do |field_name|
      @owner_model.get_property_by_name(field_name)
    end
  end


  def build_query : String

    query_to_execute = String.build do |query|

      build_insert_statement(query)
      build_values_statement(query)
      add_returning_statement(query)

    end

    query_to_execute

  end


  def build_insert_statement(query)

    query << "INSERT INTO #{get_table_name} "

    query << '('

    size_flag = @insert_into_column_names.size
    0..(size_flag - 1).times do |i|

      query << "#{@insert_into_column_names[i]}, "

    end

    query <<  "#{@insert_into_column_names[size_flag - 1]} "

    query << ") "

  end


  def build_values_statement(query)

    query << "VALUES "

    query << '('

    size_flag = @insert_into_column_names.size
    (size_flag - 1).times do |i|

      query << "$#{i + 1}, "

    end

    query <<  "$#{size_flag})"

  end

  def add_returning_statement(query)
    query << " RETURNING id;"
  end


  def get_table_name : String
    @owner_model.class.table_name
  end


end
