class Shepherd::Controller::Response404 < Shepherd::Controller::Base

  def index
    render_plain "404"
  end

end
