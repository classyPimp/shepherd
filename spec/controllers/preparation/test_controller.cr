class App::Controllers::Test < Shepherd::Controller::Base


  def home
    it "works" do
      true.should eq("false")
    end
    render plain: "HELLO THERE!"
  end

  def index : Nil
    render plain: Shepherd::Configuration::Security.secret_key
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
