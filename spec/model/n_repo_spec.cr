require "./database_preparation/db_helper"

db_helper = DBHelper.instance

describe "it works" do
  p ""
  p ""
  User.n_where
    .select(User, "name")
    .from(User)
    .where(User, {"id", :in, [1,2,3,4,5]})
    .where(User, {"name", :eq, "joe"})
    .where(User, {"age", :gt, 20})
    .where(User, {"age", :lt, 30})
    .or_where(User, {"age", :eq, 500})
    .where({"name", :eq, "no tbname"})
    .where({"notb", :in, [1,2,3,4,5,6]})
    .or_where({"notb", :eq, "no table"})
    .inner_join(&.account)
    .puts_query_and_args
  p ""
  p ""
end
