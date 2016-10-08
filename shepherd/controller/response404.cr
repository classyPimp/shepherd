#TODO: move to app domain
class Shepherd::Controller::Response404 < Shepherd::Controller::Base

  def index
    head 404
  end

end
