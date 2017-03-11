# require "./models_with_relations_classes/test_domain_base"
# require "./models_with_relations_classes/**"
#
#
# class DBHelperBtPoly
#
#   @post_node_related_to_post_text : PostNode?
#   @post_node_related_to_post_image : PostNode?
#   @post_text : PostText?
#   @post_image : PostImage?
#   @user : User?
#   @post : Post?
#
#   def initialize
#     @connection = Shepherd::Database::DefaultConnection.get
#   end
#
#   def prepare
#     #clear_user_records
#     create_user
#
#     #clear_post_records
#     create_post
#
#     # clear_post_texts_records
#     # clear_post_images_records
#     # clear_post_nodes_records
#
#     create_post_text
#     create_post_image
#     create_post_node_related_to_post_text
#     create_post_node_related_to_post_image
#
#     self
#   end
#
#   def clear_user_records
#     @connection.exec "delete from users"
#   end
#
#   def create_user
#     user = User.new
#     user.name = "joe"
#     user.repo.create
#
#     @user = user
#   end
#
#   def get_user : User
#     @user.not_nil!
#   end
#
#   def clear_post_records
#     @connection.exec "delete from posts"
#   end
#
#   def create_post
#     post = Post.new
#     post.title = "post title"
#     post.user_id = @user.not_nil!.id
#     post.repo.create
#
#     @post = post
#   end
#
#   def get_post : Post
#     @post.not_nil!
#   end
#
#   def clear_post_texts_records
#     @connection.exec "delete from post_texts"
#   end
#
#   def clear_post_images_records
#     @connection.exec "delete from post_images"
#   end
#
#   def clear_post_nodes_records
#     @connection.exec "delete from post_nodes"
#   end
#
#   def create_post_text
#     post_text = PostText.new
#     post_text.content = "post text"
#     post_text.repo.create
#     @post_text = post_text
#   end
#
#   def create_post_image
#     post_image = PostImage.new
#     post_image.content = "post image"
#     post_image.repo.create
#     @post_image = post_image
#   end
#
#   def create_post_node_related_to_post_text
#     post_node = PostNode.new
#     post_node.node_type = "PostText"
#     post_node.node_id = @post_text.not_nil!.id
#     post_node.post_id = @post.not_nil!.id
#     post_node.repo.create
#     @post_node_related_to_post_text = post_node
#   end
#
#   def create_post_node_related_to_post_image
#     post_node = PostNode.new
#     post_node.node_type = "PostImage"
#     post_node.node_id = @post_image.not_nil!.id
#     post_node.post_id = @post.not_nil!.id
#     post_node.repo.create
#     @post_node_related_to_post_image = post_node
#   end
#
#   def get_post_node_related_to_post_image : PostNode
#     PostNode.repo.where(PostNode, {"id", :in, [@post_node_related_to_post_image.not_nil!.id.not_nil!]})
#     .get[0].not_nil!
#   end
#
#   def get_post_node_related_to_post_text : PostNode
#     PostNode.repo.where(PostNode, {"id", :in, [@post_node_related_to_post_text.not_nil!.id.not_nil!]})
#     .get[0].not_nil!
#   end
#
#   def get_post_text : PostText
#     PostText.repo.where(PostText, {"id", :in, [@post_text.not_nil!.id.not_nil!]})
#     .get[0].not_nil!
#   end
#
#   def get_post_image : PostImage
#     PostImage.repo.where(PostImage, {"id", :in, [@post_image.not_nil!.id.not_nil!]})
#     .get[0].not_nil!
#   end
#
# end
