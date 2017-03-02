require "./models_with_relations_classes/test_domain_base"
require "./models_with_relations_classes/**"


class DBHelperBtPoly

  @post_node_related_to_post_text : PostNode?
  @post_node_related_to_post_image : PostNode?
  @post_text : PostText?
  @post_image : PostImage?

  def initialize
    @connection = Shepherd::Database::DefaultConnection.get

  end

  def prepare
    clear_post_texts_records
    clear_post_images_records
    clear_post_nodes_records

    create_post_text
    create_post_image
    create_post_node_related_to_post_text
    create_post_node_related_to_post_image
  end

  def clear_post_texts_records
    @connection.exec "delete from post_texts"
  end

  def clear_post_images_records
    @connection.exec "delete from post_images"
  end

  def clear_post_nodes_records
    @connection.exec "delete from post_nodes"
  end

  def create_post_text
    post_text = PostText.new
    post_text.content = "post text"
    post_text.repository.create.execute
    @post_text = post_text
  end

  def create_post_image
    post_image = PostImage.new
    post_image.content = "post image"
    post_image.repository.create.execute
    @post_image = post_image
  end

  def create_post_node_related_to_post_text
    post_node = PostNode.new
    post_node.node_type = "PostText"
    post_node.node_id = @post_text.not_nil!.id
    post_node.repository.create.execute
    @post_node_related_to_post_text = post_node
  end

  def create_post_node_related_to_post_image
    post_node = PostNode.new
    post_node.node_type = "PostImage"
    post_node.node_id = @post_image.not_nil!.id
    post_node.repository.create.execute
    @post_node_related_to_post_image = post_node
  end

  def get_post_node_related_to_post_image : PostNode
    @post_node_related_to_post_image.not_nil!
  end

  def get_post_node_related_to_post_text : PostNode
    @post_node_related_to_post_text.not_nil!
  end

  def get_post_text : PostText
    @post_text
  end

  def get_post_image : PostImage
    @post_image
  end

end
