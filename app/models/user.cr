class Models::User < Shepherd::Model::Base

  database_mapping(
    { table_name: "users",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "name": {type: String},
        "email": {type: String}
      }
    }
  )


  # associations_config(
  #   {
  #     has_many: [:accounts, {class: Account, local_key: "id", foreign_key: "user_id"}],
  #     has_one: [:account, {class: Account, local_key: "id", foreign_key: "user_id"}],
  #     belongs_to: [:account, {class: Account, local_key: "account_id", foreign_key: "id"}],
  #     has_one_through: [:account, {through: :account}],
  #     has_many: [:comments, {polymorphic: true, as: :commentable, polymorphic_id: :commentable_id}]
  #     belongs_to: [:forum, {as: :commentable}]
  #   }
  # )

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
