describe "#repo.delete" do

  it "destroys the model on which it's called" do
    user = User.new
    user.name = "to be destroyed"
    user.repo.create

    user_to_be_destroyed = User.repo.where({"name", :eq, "to be destroyed"}).get.not_nil!

    user.repo.delete

    deleted_user = User.repo.where({"name", :eq, "to be destroyed"}).get
    deleted_user.should be_a(Nil)


  end

end
