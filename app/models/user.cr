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

  #TODO: IMPLEMENT
  # association_config(
  #   {
  #     has_many: [:accounts, class: Account, local_key: "id", foreign_key: "user_id"],
  #     has_one: [:account, class: Account, local_key: "id", foreign_key: "user_id"],
  #     belongs_to: [:account, class: Account, local_key: "account_id", foreign_key: "id"]
  #   }
  # )

end
