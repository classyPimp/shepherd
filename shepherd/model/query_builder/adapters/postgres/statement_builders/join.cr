class Shepherd::Model::QueryBuilder::Adapters::Postgres::StatementBuilders::Join(T)

  @statements_io : IO::Memory
  @statements_io = IO::Memory.new(512)

  def feed(statements : Array(Shepherd::Model::JoinBuilderBase::StatementTuple)) : Nil
    statements.each do |statement|
      add_statement(statement)
    end
  end

  def add_statement(statement : Shepherd::Model::JoinBuilderBase::StatementTuple) : Nil

    insert_join_type(statement[:join_type])

    table_name_or_alias = statement[:alias_as] ? statement[:alias_as] : statement[:class_to_join].table_name.as(String)
    joined_table_name = statement[:class_to_join].table_name.as(String)
    alias_or_nil = (statement[:alias_as] ? statement[:alias_as] : nil)

    @statements_io << "#{joined_table_name} "
    @statements_io << "#{alias_or_nil}"
    @statements_io << " on #{statement[:parent].table_name.as(String)}.#{statement[:parent_column]}"
    @statements_io << " = #{table_name_or_alias}.#{statement[:class_to_join_column]} "

    if statement[:extra_join_criteria]
      @statements_io << statement[:extra_join_criteria]
    end

  end

  def insert_join_type(join_type : Shepherd::Model::JoinBuilderBase::JoinTypesEnum) : Nil
    case join_type
    when Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner
      @statements_io << "INNER JOIN "
    end
  end

  def get_statements_io : IO::Memory
    @statements_io
  end

end
