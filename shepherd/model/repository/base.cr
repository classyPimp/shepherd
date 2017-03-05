class Shepherd::Model::Repository::Base(AdapterT, ConnectionGetterT, T)

  @owner_model : T?
  property :owner_model

  def initialize(@owner_model : T)
  end

  def initialize
    @owner_model = nil
  end

  def create
    AdapterT::Create( ConnectionGetterT, T ).new(@owner_model.as(T))
  end

  def create(*, save_only field_names : Array(String))
    AdapterT::Create( ConnectionGetterT, T ).new(@owner_model.as(T), save_only: field_names)
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

  def find(id : Int32)
    AdapterT::Where( ConnectionGetterT, T).new.where({"id", :eq, id}).limit(1)
  end

end
