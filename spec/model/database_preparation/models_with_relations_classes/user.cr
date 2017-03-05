class User < Model::TestDomainBase

  database_mapping(
    { table_name: "users",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "name": {type: String},
        "email": {type: String},
        "user_id": {type: Int32},
        "friend_type": {type: String},
        "friend_id": {type: Int32},
        "age": {type: Int32}
      }
    }
  )

  associations_config({
    accounts: {
      type: :has_many, class_name: Account,
      local_key: "id", foreign_key: "user_id"
    },
    account: {
      type: :has_one, class_name: Account,
      local_key: "id", foreign_key: "user_id"
    }
    # user: {
    #   type: :has_many, through: :account,
    #   class_name: Models::User, source: :user,
    #   this_joined_through: :account, alias_on_join_as: "users_users"
    # },
    # friend: {
    #   type: :belongs_to, polymorphic: true, polymorphic_type_field: "friend_type",
    #   local_key: "friend_id", foreign_key: "id",
    #   supported_types: (Models::User | Models::Account)
    # }
    # friend: {
    #   type: :has_one, class_name: Models::User,
    #   local_key: "id", foreign_key: "friendable_id",
    #   foreign_polymorphic_key: "friendable_type"
    # },
    #user: {type: :belongs_to, class_name: Models::User, local_key: "user_id", foreign_key: "id"}
    #belongs_to :user, class_name: Models::User, local_key: "user_id", foreign_key: "id"
  })

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
