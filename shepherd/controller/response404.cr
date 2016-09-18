#TODO: move to app domain
class Shepherd::Controller::Response404 < Shepherd::Controller::Base

  def index
    render plain: "404"
  end

end
