class Shepherd::Model::Repository::Base(AdapterT, ConnectionGetterT, T)

  @owner_model : T?

  def initialize(@owner_model : T)
  end

  def initialize
    @owner_model = nil
  end

  def create
    AdapterT::Create( ConnectionGetterT, T ).new(@owner_model.as(T))
  end

  def create(*field_names) : Shepherd::QueryBuilder::Interfaces::Create
    AdapterT::Create( ConnectionGetterT, T ).new(@owner_model.as(T), *field_names)
  end

  def where(prefix, *args)
    AdapterT::Where( ConnectionGetterT, T ).new.where(prefix, *args)
  end

  def inner_join(&block : T::JoinBuilder -> Shepherd::Model::JoinBuilderBase::Interface)
    AdapterT::Where( ConnectionGetterT, T).new.inner_join(&block)
  end

  def init_where
    AdapterT::Where( ConnectionGetterT, T).new
  end

end
