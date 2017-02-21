class App::Controllers::Test < Shepherd::Controller::Base

  has_functional_actions

  def self.functional(context : HTTP::Server::Context) : Nil
    render context, plain: "Hello world!"
  end

  def instantial
    render json: {"foo" => "bar"}
  end

  def home
    render plain: "HELLO THERE!"
  end

  def json

    r = {"array" => [1, 2, 3], "dict" => {"one" => 1, "two" => 2, "three" => 3}, "int" => 42, "string" => "test", "double" => 3.14, "null" => nil}
    render json: r

  end


  def index : Nil

    # user = Models::User.new
    # user.name = "joepoly"
    # user.friend_type = "User"
    # user.friend_id = 1
    # user.repository.create.execute
    #
    # p user.friend
    # # p user.id
    # # p user.name
    # # p user.email
    # # p "done"
    # # Shepherd::Database::Connection.get.query("select * from users where id in ($1)", [[1,2,3,4]]) do |rs|
    # #
    # # end
    # collection = Models::User.repository
    #   .where(nil, {"id", :in, [22, 23, 24, 25, 26]})
    #   .inner_join(&.friend(Models::User, alias_as: "foo_users"))
    #   .execute
    #
    # collection.each do |user|
    #   p user
    # end
    p "post_node: has_many nodes polymorphic"
    collection = Models::PostNode.repository
      .where(Models::PostNode, {"id", :in, [1,2]})
      .execute

    post_node = collection[0]
    p "should load post text"
    p post_node.node

    p "should load post image"
    post_node = collection[1]
    p post_node.node


    p "post has_many post_nodes"
    collection = Models::Post.repository
      .where(Models::Post, {"id", :in, [1,2]})
      .execute

    post = collection[0]

    p post.post_nodes

    p "post has_many post_texts through polymorphic nodes"

    p post.post_texts

    p "post has_many post_images through polymorphic nodes"

    p post.post_images

    #
    # p post.post_nodes
      #.eager_load(&.user)
    # collection = Models::User.repository
    #   .inner_join(&.user)
    #   .where("users", {"id", :in, [1,2,3,4]})
    #   .execute
    #
    #
    # collection = Models::User.repository
    #   .where({"id", :eq, 1})
    #   .limit(1)
    #   .execute
    # user = collection[0]
    # user.user
    # user = collection[0]
    # user.user
    #p user.account
    #p user.user
    #p user.account.user

    render plain: Shepherd::Configuration::Security.secret_key

  end


  def foo : Nil
    render plain: "val#{context.request.cookies.to_h}"
  end

  def edit
    render plain: "test#edit"
  end

  def show
    render plain: "test#show"
  end

  def update

    file = params["file"].as(Shepherd::Server::Request::MultipartFileWrapper)

    if file

      file_name = file.meta.filename
      buffer = uninitialized UInt8[2048]
      uploaded_file_io = file.io
      p file.io.gets_to_end

      File.open( "#{Config::Application::PUBLIC_DIR}/#{file_name}", "w+") do |_file|
        if (read_bytes_length = uploaded_file_io.read(buffer.to_slice)) > 0
          _file.write( buffer.to_slice[0, read_bytes_length] )
        end
      end

    end

    render plain: "test#update"
  end

  def delete
    puts "delete"
    render plain: "test#delete"
  end

  def new
    render plain: "test#new"
  end

  def create
    render plain: "test#create"
  end

end
