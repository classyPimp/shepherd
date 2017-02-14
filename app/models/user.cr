class Models::User < Model::AppDomainBase

  database_mapping(
    { table_name: "users",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "name": {type: String},
        "email": {type: String}
      }
    }
  )

  associations_config do
    has_many :accounts, class_name: Models::Account, local_key: "id", foreign_key: "user_id"
    has_one :account, class_name: Models::Account, local_key: "id", foreign_key: "user_id"
    #has_one :user, class_name: Models::User, through: :account, joined_via: :account
  end

  # associations_config({
  #
  #     has_many: [:accounts, {class_name: Models::Account, local_key: "id", foreign_key: "user_id"}],
  #     has_one: [:account, {class_name: Models::Account, local_key: "id", foreign_key: "user_id"}]
  #     #{has_one: [:user, {class_name: Models::User, through: :account, joined_via: :account}]}
  #     # belongs_to: [:account, {class: Account, local_key: "account_id", foreign_key: "id"}],
  #     # has_many: [:comments, {polymorphic: true, as: :commentable, polymorphic_id: :commentable_id}]
  #     # belongs_to: [:forum, {as: :commentable}]
  #
  # })

  # User.new.accounts(load: true)
  # User.new.accounts(loaded?: true)
  # User.new.accounts(reload: true)
  # User.new.account(get_repository: true) do |acc|
  #   acc.eager_load(&.commenters)
  # end
  # User.new.account(get_repository: true, no_assign: true) do |acc|
  #   acc.where("foo", :eq, "bar").execute
  # end

end
