class Models::User < Shepherd::Model::Base

  database_mapping(
    { table_name: "users",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "name": {type: String},
        "email": {type: String},
        "age": {type: Int32}
      }
    }
  )


  # associations_config(
  #   {
  #     has_many: [:accounts, class: Account, local_key: "id", foreign_key: "user_id"],
  #     has_one: [:account, class: Account, local_key: "id", foreign_key: "user_id"],
  #     belongs_to: [:account, class: Account, local_key: "account_id", foreign_key: "id"],
  #     has_one_through: [:account, through: :account]
  #   }
  # )

end
