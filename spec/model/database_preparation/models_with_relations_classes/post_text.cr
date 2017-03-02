class PostText < Model::TestDomainBase

  database_mapping(
    { table_name: "post_texts",
      column_names: {
        "id": {type: Int32, primary_key: true},
        "content": {type: String}
      }
    }
  )
  #
  #
  associations_config({
    post_nodes: {
      type: :has_many, class_name: PostNode,
      local_key: "id", foreign_key: "node_id"#, as: "PostText",
      #foreign_polymorphic_field: "node_type"
    }
  })

end
