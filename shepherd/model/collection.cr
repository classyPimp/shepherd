class Shepherd::Model::Collection(T)

  include Enumerable(T)

  property :collection
  @collection : Array(T)


  def initialize()
    @collection = Array(T).new
  end


  def each(&block : T -> _)
    @collection.each(&block)
  end

  def <<(value : T) : Array(T)
    @collection << value
    @collection
  end
  
end
