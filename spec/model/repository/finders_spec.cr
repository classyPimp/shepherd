require "../database_preparation/db_helper"

db_helper = DBHelper.instance

describe "#repository.where" do

  it "returns collection of model if found any" do
     user = User.new
     user.name = "asdasd"
     user.repository.create.execute

     user = User.new
     user.name = "asdasd"
     user.repository.create.execute

     users = User.repository
      .where({"name", :eq, "asdasd"})
      .execute

     users.should be_a(Shepherd::Model::Collection(User))
     users.size.should eq(2)

  end

  it "when recieves :eq as operator builds =" do
    user = User.repository
      .where({"name", :eq, "asdasd"}) #depends if previous in this test created  with such name
      .execute[0]?

    user.should be_a(User)

  end

  it "when recieves :gt as operator builds >" do

    user = User.new
    user.age = 30
    user.repository.create.execute

    that_user = User.repository
      .where({"age", :gt, user.age.not_nil! - 1})
      .execute[0].not_nil!

    that_user.id.should eq(user.id)

  end

  it "when recieves :lt as operator builds <" do

    user = User.new
    user.age = 20
    user.repository.create.execute

    that_user = User.repository
      .where({"age", :lt, user.age.not_nil! + 1})
      .execute[0].not_nil!

    that_user.id.should eq(user.id)

  end

  describe "where(raw_query : String, *args)" do
    it "builds non conflicting with other statements where statemes" do
      user = User.repository
        .where({"id", :gt, 0})
        .where("users.age = $2", 20)
        .execute[0]

      user.should be_a(User)

    end
  end

end

describe "#repository.find" do

  it "returns the model if found" do
    user = User.new
      user.name = "awdgvasdv"
      user.repository.create.execute

    that_user = User.repository.find(user.id.not_nil!).execute[0]?
    that_user.should be_a(User)
  end

end
