require "../../database_preparation/db_helper"



module Associations
  module HasMany

    db_helper = DBHelper.instance

    describe "Plain" do

      describe "#relations" do

        it "should query dependent and return collection of dependents" do

          db_helper.fetch_post.accounts.should be_a(
            Shepherd::Model::Collection(Account)
          )
        end

        it "returned collection's first index value should be related model" do

          db_helper.fetch_post.accounts[-1].not_nil!.should be_a(
            Account
          )
        end

        it "queries and returns all realted models" do

          size = db_helper.fetch_post.accounts.size
          size.should eq(2)
        end

      end

      describe "#relations(load: false)" do

        it "should return collection of related values anyway" do

          db_helper.fetch_post.accounts(load: false).should be_a(
            Shepherd::Model::Collection(Account)
          )
        end

        it "should not load related model" do

          db_helper.fetch_post.accounts(load: false)[0]?.should be_a(
            Nil
          )
        end

      end

      describe "#realations(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do

          db_helper.fetch_post.accounts(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relations" do

          post = db_helper.fetch_post
          post.accounts(yield_repository: true) do |repo|
            repo.execute
          end
          post.accounts(load: false)[0].not_nil!.should be_a(Account)
        end

      end

      describe "RELATION JOIN #repository#where.inner_join(&.relations)" do

        it "should validly join related model" do

          Post.repository
            .inner_join(&.accounts)
            .where(Account, {"name", :eq, "account"})
            .execute[0]
            .not_nil!
            .should be_a(Post)

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relations)" do

        it "should eagerly load related models" do

          post = Post.repository
                  .where(Post, {"title", :eq, "post title"})
                  .eager_load(&.accounts)
                  .execute[0].not_nil!

          post.accounts(load: false)[0].not_nil!.should be_a(Account)

        end


      end


    end

  end
end
