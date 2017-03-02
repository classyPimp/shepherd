class Models::PostText < Model::AppDomainBase

  # database_mapping(
  #   { table_name: "post_texts",
  #     column_names: {
  #       "id": {type: Int32, primary_key: true},
  #       "content": {type: String}
  #     }
  #   }
  # )
  #
  #
  # associations_config({
  #   post_nodes: {
  #     type: :has_many, class_name: Models::PostNode,
  #     local_key: "id", foreign_key: "node_id", as: "PostText",
  #     foreign_polymorphic_field: "node_type"
  #   }#,
  #   # posts: {
  #   #   type: :has_many, class_name: Models::Post,
  #   #   local_key: "id", foreign_key: "post_id", through: :post_nodes,
  #   #   this_joined_through: :post_nodes, joined_via: :post, this_joined_as: "PostText"
  #   # }
  # })

end
