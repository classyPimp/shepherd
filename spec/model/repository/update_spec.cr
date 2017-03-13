describe "#repo.udpate" do

  it "updates the model" do
    user = User.new
    user.name = "to_be_updated"
    user.repo.create

    that_user = User.repo.where({"name", :eq, "to_be_updated"}).get.not_nil!

    that_user.name = "update_done"
    that_user.repo.update

    tested_user = User.repo.where({"name", :eq, "update_done"}).get.not_nil!

    tested_user.name.should eq("update_done")

  end

end
