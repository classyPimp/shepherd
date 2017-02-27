require "./models_with_relations_classes/test_domain_base"
require "./models_with_relations_classes/**"

class DBForAssociationsPreparator

  @single_user : User?
  @single_account : Account?

  def initialize
    @connection = Shepherd::Database::DefaultConnection.get

  end

  def prepare_for_plain_relations
    clear_user_records
    create_single_user

    clear_account_records
    create_single_account_that_belongs_to_user

    self
  end

  def clear_user_records
    @connection.exec "delete from users"
  end

  def create_single_user
    user = User.new
    user.name = "joe"
    user.repository.create.execute

    @single_user = user
  end


  def clear_account_records
    @connection.exec "delete from accounts"
  end

  def create_single_account_that_belongs_to_user
    account = Account.new
    account.name = "account"
    account.user_id = @single_user.not_nil!.id

    account.repository.create.execute

    @single_account = account
  end

  def get_user : User
    @single_user.not_nil!
  end

  def get_account : Account
    @single_account.not_nil!
  end

  @post_node_related_to_post_text : PostNode?
  @post_node_related_to_post_image : PostNode?
  @post_text : PostText?
  @post_image : PostImage?


  def prepare_for_belongs_to_polymorphic
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
    post_node.node_type = 'PostText'
    post_node.node_id = @post_text.not_nil!.id
    post_node.repository.create.execute
    @post_node_related_to_post_text = post_node
  end

  def create_post_node_related_to_post_image
    post_node = PostNode.new
    post_node.node_type = 'PostImage'
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
