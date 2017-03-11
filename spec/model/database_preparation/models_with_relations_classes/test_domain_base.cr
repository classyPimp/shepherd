class Model::TestDomainBase < Shepherd::Model::Base



  default_repository({
    connection: Shepherd::Database::DefaultConnection,
    adapter: :Postgres
  })


  #
  # add_repository(
  #   accessor_method: mysql_secondary_repository,
  #   connection: MyCustomConnection,
  #   adapter: :mysql
  # )
  # def mysql_secondary_repository : Shepherd::Model::Repository::Base
  #   Shepherd::Model::Repository::Base(Shepherd::Model::QueryBuilder::Adapters::Mysql, MyCustomConnection, self).new(self)
  # end
  #
  # def self.mysql_secondary_repository : Shepherd::Model::Repository::Base
  #   Shepherd::Model::Repository::Base(Shepherd::Model::QueryBuilder::Adapters::Mysql, MyCustomConnection, self).new
  # end
  #
  # user = User.repository.where("id", :eq, 2).execute
  # user_account = Account.mysql_secondary_repository.where("user_id", :eq, user.id).execute
  #
  # def repository : Shepherd::Model::Repository::Base
  #   Shepherd::Model::Repository::Base(Shepherd::Model::QueryBuilder::Adapters::Postgres, Shepherd::Database::DefaultConnection, self).new(self)
  # end
  #
  # def self.repository : Shepherd::Model::Repository::Base
  #   Shepherd::Model::Repository::Base(Shepherd::Model::QueryBuilder::Adapters::Postgres, Shepherd::Database::DefaultConnection, self).new
  # end

end
