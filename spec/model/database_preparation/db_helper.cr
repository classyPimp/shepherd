require "./models_with_relations_classes/test_domain_base"
require "./models_with_relations_classes/**"

class DBHelper

  INSTANCE = new

  def self.instance
    INSTANCE
  end

  @user : User
  @account : Account
  @second_account : Account
  @post : Post
  @post_text : PostText
  @post_image : PostImage
  @post_node_btp_post_text : PostNode
  @post_node_btp_post_image : PostNode

  def initialize
    @connection = Shepherd::Database::DefaultConnection.get
    clear_previously_created
    @user = create_user
    @account = create_account
    @second_account = create_account(name: "account1")
    @post = create_post
    @post_text = create_post_text
    @post_image = create_post_image
    @post_node_btp_post_text = create_post_node_btp_post_text
    @post_node_btp_post_image = create_post_node_btp_post_image
    self
  end

  def clear_previously_created
    @connection.exec "delete from users"
    @connection.exec "delete from posts"
    @connection.exec "delete from accounts"
    @connection.exec "delete from users"
    @connection.exec "delete from post_texts"
    @connection.exec "delete from post_images"
    @connection.exec "delete from post_nodes"
  end

  def create_user
    user = User.new
    user.name = "joe"
    user.repo.create
    user
  end

  def create_account(*, name : String = "account")
    account = Account.new
    account.name = name
    account.user_id = @user.not_nil!.id

    account.repo.create

    account
  end

  def create_post
    post = Post.new
    post.title = "post title"
    post.user_id = @user.not_nil!.id
    post.repo.create

    post
  end

  def create_post_text
    post_text = PostText.new
    post_text.content = "post text"
    post_text.repo.create
    post_text
  end

  def create_post_image
    post_image = PostImage.new
    post_image.content = "post image"
    post_image.repo.create
    post_image
  end

  def create_post_node_btp_post_text
    post_node = PostNode.new
    post_node.node_type = "PostText"
    post_node.node_id = @post_text.not_nil!.id
    post_node.post_id = @post.not_nil!.id
    post_node.repo.create

    post_node
  end

  def create_post_node_btp_post_image
    post_node = PostNode.new
    post_node.node_type = "PostImage"
    post_node.node_id = @post_image.not_nil!.id
    post_node.post_id = @post.not_nil!.id
    post_node.repo.create

    post_node
  end



  def fetch_post : Post
    Post.repo.where(Post, {"id", :in, [@post.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_user : User
    User.repo.where(User, {"id", :in, [@user.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_account : Account
    Account.repo.where(Account, {"id", :in, [@account.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_second_account : Account
    Account.repo.where(Account, {"id", :in, [@second_account.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_post : Post
    Post.repo.where(Post, {"id", :in, [@post.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_post_text : PostText
    PostText.repo.where(PostText, {"id", :in, [@post_text.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_post_image : PostImage
    PostImage.repo.where(PostImage, {"id", :in, [@post_image.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_post_node_btp_post_text : PostNode
    PostNode.repo.where(PostNode, {"id", :in, [@post_node_btp_post_text.not_nil!.id.not_nil!]})
    .get.not_nil!
  end

  def fetch_post_node_btp_post_image : PostNode
    PostNode.repo.where(PostNode, {"id", :in, [@post_node_btp_post_image.not_nil!.id.not_nil!]})
    .get.not_nil!
  end


end
