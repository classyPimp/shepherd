class Shepherd::Model::Repository( T )

  def initialize(@owner_model : T)

  end

  def create
    Shepherd::Model::QueryBuilder::Create::Postgres( T ).new(@owner_model)
  end

  def create(*field_names) : Shepherd::QueryBuilder::Interfaces::Create
    Shepherd::Model::QueryBuilder::Create::Postgres( T ).new(@owner_model, *field_names)
  end

end
