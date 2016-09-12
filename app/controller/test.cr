class App::Controller::Test < Shepherd::Controller::Base

  def index : Void

    encoded_form = ""
    params.encoded_form.each do |k, v|
      encoded_form += "#{k} => #{v}"
    end

    render_plain "
      route_params: #{params.route}
      body: #{params.body}
      json: #{params.json}
      encoded_form: #{encoded_form}
      query: #{params.url_query}
    "
  end

end
