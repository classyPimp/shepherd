class PostText < Model::TestDomainBase

  database_mapping(
    { table_name: "post_texts",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "content": {type: String},
        "post_id": {type: Int32}
      }
    }
  )
  #
  #
  associations_config({
    post_node: {
      type: :has_one, class_name: PostNode,
      local_key: "id", foreign_key: "node_id",
      foreign_polymorphic_type_field: "node_type",
    },
    post_nodes: {
      type: :has_many, class_name: PostNode,
      local_key: "id", foreign_key: "node_id",
      foreign_polymorphic_type_field: "node_type"
    }
  })

end
