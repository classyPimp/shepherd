class Shepherd::Model::JoinBuilderBase

  alias StatementTuple = NamedTuple(
    join_type: JoinTypesEnum,
    parent: Shepherd::Model::Base.class,
    class_to_join: Shepherd::Model::Base.class,
    parent_column: String,
    class_to_join_column: String,
    alias_as: String?,
    extra_join_criteria: String?#Array(Tuple(Symbol, String, Symbol, DB::Any))? #TODO: refactor to accept like {and: {x, :eq, z}}
    #for adapter to build statement (now it's hardcoded as string "and x.foo = 'bar'" which can be implemented differently on another DB's)
  )

  @join_statements : Array(StatementTuple)
  @join_type : JoinTypesEnum

  def initialize(@join_type : JoinTypesEnum, @join_statements : Array(StatementTuple))
  end

  def initialize(@join_type : JoinTypesEnum)
    @join_statements = Array(StatementTuple).new(5)
  end

  def get_statements : Array(StatementTuple)
    @join_statements
  end

  def inner_join(&block : self -> Shepherd::Model::JoinBuilderBase::Interface)
    @join_type = JoinTypesEnum::Inner
    yield self
    self
  end

  enum JoinTypesEnum
    Inner
    Left
    Right
  end

  module Interface

  end

end
