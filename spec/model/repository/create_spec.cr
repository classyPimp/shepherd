require "../database_preparation/db_helper"

db_helper = DBHelper.instance

describe "#repo.create" do
  it "creates model, saving all the dbfield properties that it has" do
    user = User.new
    user.name = "joe schmoe"
    user.email = "joe@schmoe.com"
    user.repo.create

    user = User.repo.where({"name", :eq, "joe schmoe"})
      .limit(1)
      .get.not_nil!

    user.name.should eq("joe schmoe")
    user.email.should eq("joe@schmoe.com")
  end

  it "assignes returned primary key value to model" do
    user = User.new
    user.name = "joe schmoe"
    user.email = "joe@schmoe.com"
    user.repo.create

    user.id.should be_a(Int32)
  end

  it "if recieved save_only : arguments, will save only those fields" do
    user = User.new
    user.name = "joe schmoe the2nd"
    user.email = "joe2nd@schmoe.com"

    user.repo
    .create("name")

    user = User.repo.where({"name", :eq, "joe schmoe the2nd"})
      .limit(1)
      .get.not_nil!

    user.name.should eq("joe schmoe the2nd")
    user.email.should eq(nil)
  end

  # it "NEWRPO" do
  #   user = User.new
  #   user.name = "foo"
  #   repo = Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(
  #     Shepherd::Database::DefaultConnection,
  #     User
  #   ).new(user).create("name", "email")
  # end

end
