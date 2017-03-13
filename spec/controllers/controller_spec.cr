require "http/client"


describe "making req" do
  it "works" do

    response = HTTP::Client.get "localhost:3000/"
    p response.status_code      # => 200
    p response.body.lines.first

  end

end
