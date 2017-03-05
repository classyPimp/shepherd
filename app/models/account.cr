class Models::Account < Model::AppDomainBase

  def self.table_name : String
    @@table_name
  end

  database_mapping(
    { table_name: "accounts",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "name": {type: String},
        "user_id": {type: Int32}
      }
    }
  )

  associations_config({
    user: {
      type: :belongs_to, class_name: Models::User,
      local_key: "user_id", foreign_key: "id"
    }
  })
  # associations_config(
  #   {
  #     has_many: [:users, {class_name: Models::User, local_key: "id", foreign_key: "account_id"}],
  #     belongs_to: [:user, {class_name: Models::User, local_key: "user_id", foreign_key: "id"}]#,
  #     # has_one: [:account, {class: Account, local_key: "id", foreign_key: "user_id"}],
  #     # has_one_through: [:account, {through: :account}],
  #     # has_many: [:comments, {polymorphic: true, as: :commentable, polymorphic_id: :commentable_id}]
  #     # belongs_to: [:forum, {as: :commentable}]
  #   }
  # )

end
