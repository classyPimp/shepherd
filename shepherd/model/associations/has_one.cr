require "./types_enum"

class Shepherd::Model::Associations::HasOne < Shepherd::Model::Associations::Base

  @master_class : Shepherd::Model::Base
  @slave_class : Shepherd::Model::Base
  @association_type : Shepherd::Model::Associations::TypesEnum
  @association_type = Shepherd::Model::Associations::TypesEnum::HasOne
  @local_key : String
  @foreign_key : String

  def initialize(@master_class, @slave_class, @local_key, @foreign_key)
  end

end

#
#
# user = User.new
#
# def account
#   unless @_account_loaded
#     @account = Account.repository.where({"user_id =": self.id}).execute.first
#   else
#     @account
#   end
# end
#
# def account(*, reload : Bool)
#   @account = Account.repository.where({"user_id =": self.id}).execute.first
# end
#
# def account(yield_repository: true, &block)
#   account = yield Account.repository
#   @account = account.as(TYPE)
#   @_account_loaded = true
# end
#
# user.account(load: true)
#
# user.account
#
# user.account(reload: true)
#
# user.account do |account_repository|
#   account_repository.eager_load(&.address).execute
# end
