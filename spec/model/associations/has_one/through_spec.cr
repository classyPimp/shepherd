require "../../database_preparation/db_helper"



module Associations
  module HasOne


    db_helper = DBHelper.instance

    describe "has_one (through)" do

      describe "#relation" do

        it "should query dependent and assign dependent to #relation" do
          db_helper.fetch_post.account.not_nil!.should be_a(
            Account
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model and return value at corresponding property" do

          db_helper.fetch_post.account(load: false).should be_nil
        end

      end

      describe "#realation(yield_repo: true, &block)" do

        it "returns #repo : Repository of related model" do

          db_helper.fetch_post.account(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #get called on repo returned value should be assigned to #relation" do
          post = db_helper.fetch_post
          post.account(yield_repo: true) do |repo|
            res = repo.get
            res
          end
          post.account(load: false).not_nil!.should be_a(Account)
        end
      end


      describe "RELATION JOIN #repo#where.inner_join(&.relation)" do

        it "should validly join related model" do

          post = Post.repo
            .inner_join(&.account)
            .where(Account, {"name", :eq, "account"})
            .get
            .not_nil!

          post.account.not_nil!.name.should eq("account")

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relation)" do

        it "should eagerly load related models" do

          post = Post.repo
                  .where(Post, {"title", :eq, "post title"})
                  .eager_load(&.account)
                  .get.not_nil!

          post.account(load: false).not_nil!.should be_a(Account)

        end


      end


    end

  end
end
