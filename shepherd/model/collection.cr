class Shepherd::Model::Collection(T)

  include Enumerable(T)
  include Indexable(T)

  property :collection
  @collection : Array(T)


  def initialize()
    @collection = Array(T).new
  end

  def [](index : Int32) : T
    @collection[index]
  end

  def []?(index : Int32) : T?
    @collection[index]?
  end

  def each(&block : T -> Nil)
    @collection.each(&block)
  end

  def <<(value : T) : Array(T)
    @collection << value
    @collection
  end

  def size
    @collection.size
  end

end
