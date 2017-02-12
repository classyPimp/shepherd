class Shepherd::Model::Repository( T )

  @owner_model : T?

  def initialize(@owner_model : T)

  end

  def initialize
    @owner_model = nil
  end

  def create
    DATABASE_ADAPTER::Create( T ).new(@owner_model.as(T))
  end

  def create(*field_names) : Shepherd::QueryBuilder::Interfaces::Create
    DATABASE_ADAPTER::Create( T ).new(@owner_model.as(T), *field_names)
  end

  def where(prefix, *args)
    DATABASE_ADAPTER::Where( T ).new.where(prefix, *args)
  end

  def inner_join(&block : T::JoinBuilder -> Shepherd::Model::JoinBuilderBase::Interface)
    DATABASE_ADAPTER::Where( T ).new.inner_join(&block)
  end

  def init_where
    DATABASE_ADAPTER::Where(T).new
  end

end
