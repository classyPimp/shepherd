class Post < Model::TestDomainBase

  database_mapping(
    { table_name: "posts",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "title": {type: String},
        "user_id": {type: Int32}
      }
    }
  )
  #

  associations_config({
    user: {
      type: :belongs_to, class_name: User,
      local_key: "user_id", foreign_key: "id"
    },
    account: {
      type: :has_one, class_name: Account,
      through: :user, this_joined_through: :user,
      that_joined_through: :account#, alias_on_join_as: "user_posts"
    },
    accounts: {
      type: :has_many, class_name: Account,
      through: :user, this_joined_through: :user,
      that_joined_through: :account
    }
  })
  # associations_config({
  #   post_nodes: {
  #     type: :has_many, class_name: Models::PostNode,
  #     local_key: "id", foreign_key: "post_id"
  #   },
  #   post_texts: {
  #     type: :has_many, class_name: Models::PostText,
  #     through: :post_nodes, joined_via: :node,
  #     polymorphic_type_field: "node_type",
  #     foreign_key: "node_id",
  #     this_joined_through: :post_nodes,
  #     this_joined_as: "PostText"
  #   },
  #   post_images: {
  #     type: :has_many, class_name: Models::PostImage,
  #     through: :post_nodes, joined_via: :node,
  #     polymorphic_through: true, polymorphic_type_field: "node_type",
  #     polymorphic_foreign_key: "node_id",
  #     this_joined_through: :post_nodes,
  #     this_joined_as: "PostImage"
  #   }
  #   # friend: {
  #   #   type: :has_one, class_name: Models::User,
  #   #   local_key: "id", foreign_key: "friendable_id",
  #   #   foreign_polymorphic_key: "friendable_type"
  #   # },
  #   #user: {type: :belongs_to, class_name: Models::User, local_key: "user_id", foreign_key: "id"}
  #   #belongs_to :user, class_name: Models::User, local_key: "user_id", foreign_key: "id"
  # })

end
