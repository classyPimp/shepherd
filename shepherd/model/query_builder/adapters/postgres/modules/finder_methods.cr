module Shepherd::Model::QueryBuilder::Adapters::Postgres::Modules::FinderMethods(T)

  #select and overloads
  #table name resolved automatically
  def select(*field_names : String) : self
    @select_builder.add_statement(*field_names)
    self
  end
  #tablename provided overload
  def select(table_name : (String | Shepherd::Model::Base.class | Nil), *field_names : String) : self
    table_name = resolve_table_name(table_name)
    @select_builder.add_statement(table_name, *field_names)
    self
  end
  #/select and overloads

  #from and overloads
  def from(table_name : (String | Shepherd::Model::Base.class | Nil)) : self
    table_name = resolve_table_name(table_name)
    @from_builder.add_statement(table_name)
    self
  end

  #/from and overloads
  #
  #where and overloads
  def where(table_name : (String | Shepherd::Model::Base.class | Nil), *args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(table_name)
    get_or_init_where_builder.add_statement(table_name, *args)
    self
  end

  #table_name inferred overload
  def where(*args : Tuple(String, Symbol, DB::Any)) : self
    table_name = T.table_name
    get_or_init_where_builder.add_statement(table_name, *args)
    self
  end

  #Overload for handling IN statement (for future any other that supplies array)
  def where(table_name : (String | Shepherd::Model::Base.class | Nil), triplet : Tuple(String, Symbol, Array))

    table_name = resolve_table_name(table_name)

    get_or_init_where_builder.add_statement(table_name, triplet)

    self

  end
  #IN table_name inferred
  def where(triplet : Tuple(String, Symbol, Array))
    table_name = resolve_table_name(T)
    get_or_init_where_builder.add_statement(table_name, triplet)

    self

  end
  #/where and overloads
  #or_where and overloads
  def or_where(table_name : (String | Shepherd::Model::Base.class | Nil), *args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(table_name)
    get_or_init_where_builder.or_where(table_name, *args)
    self
  end
  #tablename inferred overload
  def or_where(*args : Tuple(String, Symbol, DB::Any)) : self
    table_name = resolve_table_name(T)
    get_or_init_where_builder.or_where(table_name, *args)
    self
  end
  #raw query overload
  def where(raw_query : String, *args : DB::Any) : self
    get_or_init_where_builder.raw_where(raw_query, *args)
    self
  end
  #/or_where and overloads
  #join and overloads
  #inner_join adn overloads
  def inner_join(&block) : self
    join_builder = yield T::JoinBuilder.new(Shepherd::Model::JoinBuilderBase::JoinTypesEnum::Inner)
    get_or_init_join_builder.feed(join_builder.get_statements)
    self
  end
  #/inner_join and overloads
  #/join and overloads
  #
  #order
  def order(table_name : (String | Shepherd::Model::Base.class | Nil), *args : String, direction : Symbol) : self
    table_name = resolve_table_name(table_name)
    get_or_init_order_builder.add_statement(table_name, *args, direction: direction)
    self
  end
  #/order
  #limit
  def limit(amount : Int32) : self
    get_or_init_limit_builder.add_statement(amount)
    self
  end
  #/limit
  #eager_load and overloads
  def eager_load(&block : T::EagerLoader -> Nil)

    eager_loader = T::EagerLoader.new
    eager_loaders << eager_loader

    yield eager_loader

    self
  end

end
