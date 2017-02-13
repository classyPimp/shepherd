class Shepherd::Database::DefaultConnection

  @@connection : DB::Database?

  def self.set_connection(connection : DB::Database)
    @@connection = connection
  end

  def self.get : DB::Database
    @@connection.not_nil!
  end

end
