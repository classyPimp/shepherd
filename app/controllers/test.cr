class App::Controllers::Test < Shepherd::Controller::Base

  has_functional_actions

  def self.functional(context)
    render context, plain: "Hello world!"
  end

  def instantial
    render plain: "Hello world"
  end

  def json

    r = {"array" => [1, 2, 3], "dict" => {"one" => 1, "two" => 2, "three" => 3}, "int" => 42, "string" => "test", "double" => 3.14, "null" => nil}
    render json: r

  end

  def index : Nil
    render plain: "test#index"
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
