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

    user = Models::User.new
    user.name = "Joe"
    user.age = 20
    user.email = "joe@doe.com"
    user.repository.create.execute

    p user.id
    p user.name
    p user.email
    p "done"
    render plain: "foo"
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
