require "../database_preparation/db_helper"

db_helper = DBHelper.instance

describe "#repo.where" do

  it "returns collection of model if found any" do
     user = User.new
     user.name = "asdasd"
     user.repo.create

     user = User.new
     user.name = "asdasd"
     user.repo.create

     users = User.repo
      .where({"name", :eq, "asdasd"})
      .get

     users.should be_a(Shepherd::Model::Collection(User))
     users.size.should eq(2)

  end

  it "when recieves :eq as operator builds =" do
    user = User.repo
      .where({"name", :eq, "asdasd"}) #depends if previous in this test created  with such name
      .get[0]?

    user.should be_a(User)

  end

  it "when recieves :gt as operator builds >" do

    user = User.new
    user.age = 30
    user.repo.create

    that_user = User.repo
      .where({"age", :gt, user.age.not_nil! - 1})
      .get[0].not_nil!

    that_user.id.should eq(user.id)

  end

  it "when recieves :lt as operator builds <" do

    user = User.new
    user.age = 20
    user.repo.create

    that_user = User.repo
      .where({"age", :lt, user.age.not_nil! + 1})
      .get[0].not_nil!

    that_user.id.should eq(user.id)

  end

  describe "where(raw_query : String, *args)" do
    it "builds non conflicting with other statements where statemes" do
      user = User.repo
        .where({"id", :gt, 0})
        .where("users.age = $2", 20)
        .get[0]

      user.should be_a(User)

    end
  end

  describe "inner_join(raw_join_statement):" do
    it  "joins non conflictly" do

      # user = User.repo
      #   .where({"id", :gt, 0})
      #   .inner_join(&.accounts)
      #   .raw_join("INNER JOIN accounts foos on foos.user_id = users.id")
      #   .get

    end
  end


  describe "#order_by(col_name, order, prefix : table_name)" do

    it "orders asc" do
      user = User.repo
        .order(User, "id", direction: :desc)
        .limit(1)
        .get[0]

      user.should be_a(User)
      user.email = "UPDATEDEMAIL!"
      user.repo.update("name", "email")
    end

  end

end

describe "#repo.find" do

  # it "returns the model if found" do
  #   user = User.new
  #     user.name = "awdgvasdv"
  #     user.repo.create
  #
  #   that_user = User.repo.find(user.id.not_nil!)[0]?
  #   that_user.should be_a(User)
  # end

end
