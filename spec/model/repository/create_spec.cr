require "../database_preparation/db_helper"

db_helper = DBHelper.instance

describe "#repository.create.execute" do
  it "creates model, saving all the dbfield properties that it has" do
    user = User.new
    user.name = "joe schmoe"
    user.email = "joe@schmoe.com"
    user.repository.create.execute

    user = User.repository.where({"name", :eq, "joe schmoe"})
      .limit(1)
      .execute[0].not_nil!

    user.name.should eq("joe schmoe")
    user.email.should eq("joe@schmoe.com")
  end

  it "assignes returned primary key value to model" do
    user = User.new
    user.name = "joe schmoe"
    user.email = "joe@schmoe.com"
    user.repository.create.execute

    user.id.should be_a(Int32)
  end

  it "if recieved save_only : arguments, will save only those fields" do
    user = User.new
    user.name = "joe schmoe the2nd"
    user.email = "joe2nd@schmoe.com"

    user.repository
    .create(save_only: ["name"]).execute

    user = User.repository.where({"name", :eq, "joe schmoe the2nd"})
      .limit(1)
      .execute[0].not_nil!

    user.name.should eq("joe schmoe the2nd")
    user.email.should eq(nil)
  end
end
