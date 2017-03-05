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

        it "should not load related model" do

          db_helper.fetch_post.account(load: false).should be_nil
        end

      end

      describe "#realation(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do

          db_helper.fetch_post.account(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relation" do
          post = db_helper.fetch_post
          post.account(yield_repository: true) do |repo|
            res = repo.execute
            res[0]?
          end
          post.account(load: false).not_nil!.should be_a(Account)
        end
      end


      describe "RELATION JOIN #repository#where.inner_join(&.relation)" do

        it "should validly join related model" do


          post = Post.repository
            .inner_join(&.account)
            .where(Account, {"name", :eq, "account"})
            .execute[0]
            .not_nil!

          post.account.not_nil!.name.should eq("account")

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relation)" do

        it "should eagerly load related models" do


          post = Post.repository
                  .where(Post, {"title", :eq, "post title"})
                  .eager_load(&.account)
                  .execute[0].not_nil!

          post.account(load: false).not_nil!.should be_a(Account)

        end


      end


    end

  end
end
