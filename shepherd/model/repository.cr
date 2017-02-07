class Shepherd::Model::Repository( T )

  def initialize(@owner_model : T)

  end

  def initialize
    @owner_model = nil
  end

  def create
    Shepherd::Model::QueryBuilder::Adapters::Postgres::Create( T ).new(@owner_model)
  end

  def create(*field_names) : Shepherd::QueryBuilder::Interfaces::Create
    Shepherd::Model::QueryBuilder::Adapters::Postgres::Create( T ).new(@owner_model, *field_names)
  end

  def where(prefix, *args)
    Shepherd::Model::QueryBuilder::Adapters::Postgres::Where( T ).new.where(prefix, *args)
  end

  def join(*args)
    Shepherd::Model::QueryBuilder::Adapters::Postgres::Where( T ).new.join(args)
  end

end
