require "./models_with_relations_classes/test_domain_base"
require "./models_with_relations_classes/**"

class DBHelperHmHoBtPLain

  @single_user : User?
  @single_account : Account?

  def initialize
    @connection = Shepherd::Database::DefaultConnection.get

  end

  def prepare_for_plain_relations
    clear_user_records
    create_single_user

    clear_account_records
    create_single_account_that_belongs_to_user
    create_single_account_that_belongs_to_user(name: "account1")

    self
  end

  def clear_user_records
    @connection.exec "delete from users"
  end

  def create_single_user
    user = User.new
    user.name = "joe"
    user.repository.create.execute

    @single_user = user
  end


  def clear_account_records
    @connection.exec "delete from accounts"
  end

  def create_single_account_that_belongs_to_user(*, name : String = "account")
    account = Account.new
    account.name = name
    account.user_id = @single_user.not_nil!.id

    account.repository.create.execute

    @single_account = account
  end

  def get_user : User
    @single_user.not_nil!
  end

  def get_account : Account
    @single_account.not_nil!
  end

end
