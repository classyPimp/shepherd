class PostNode < Model::TestDomainBase

  database_mapping(
    { table_name: "post_nodes",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "node_type": {type: String},
        "node_id": {type: Int32},
        "post_id": {type: Int32}
      }
    }
  )
  #
  #
  associations_config({
    # post: {
    #   type: :belongs_to, class_name: Models::Post,
    #   local_key: "post_id", foreign_key: "id"
    # },
    node: {
      type: :belongs_to, polymorphic: true, polymorphic_type_field: "node_type",
      local_key: "node_id", foreign_key: "id",
      supported_types: (PostText | PostImage)
    }
    # friend: {
    #   type: :has_one, class_name: Models::User,
    #   local_key: "id", foreign_key: "friendable_id",
    #   foreign_polymorphic_key: "friendable_type"
    # },
    #user: {type: :belongs_to, class_name: Models::User, local_key: "user_id", foreign_key: "id"}
    #belongs_to :user, class_name: Models::User, local_key: "user_id", foreign_key: "id"
  })

end
