class App::Controller::Test < Shepherd::Controller::Base

  def index : Void

  end


  def foo
    render_plain "val#{context.request.cookies.to_h}"
  end

end
