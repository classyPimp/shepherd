require "../../database_preparation/db_helper"



module Associations
  module HasMany


    db_helper = DBHelper.instance

    describe "has_many (plain)" do

      describe "#relations" do

        it "should query dependent and return collection of dependents" do

          db_helper.fetch_user.accounts.should be_a(
            Shepherd::Model::Collection(Account)
          )
        end

        it "returned collection's first index value should be related model" do

          db_helper.fetch_user.accounts[-1].not_nil!.should be_a(
            Account
          )
        end

        it "queries and returns all realted models" do

          size = db_helper.fetch_user.accounts.size
          size.should eq(2)
        end

      end

      describe "#relations(load: false)" do

        it "should return collection of related values anyway" do

          db_helper.fetch_user.accounts(load: false).should be_a(
            Shepherd::Model::Collection(Account)
          )
        end

        it "should not load related model" do

          db_helper.fetch_user.accounts(load: false)[0]?.should be_a(
            Nil
          )
        end

      end

      describe "#realations(yield_repo: true, &block)" do

        it "returns repo#where : QueryBuilder of related model" do

          db_helper.fetch_user.accounts(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #get called on repo returned value should be assigned to #relations" do

          user = db_helper.fetch_user
          user.accounts(yield_repo: true) do |repo|
            repo.list
          end

          user.accounts(load: false)[0].not_nil!.should be_a(Account)
        end

      end

      describe "RELATION JOIN #repo#where.inner_join(&.relations)" do

        it "should validly join related model" do


          User.repo
            .inner_join(&.accounts)
            .where(Account, {"name", :eq, "account"})
            .get
            .not_nil!
            .should be_a(User)

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relations)" do

        it "should eagerly load related models" do


          user = User.repo
                  .where(User, {"name", :eq, "joe"})
                  .eager_load(&.accounts)
                  .get.not_nil!

          user.accounts(load: false)[0].not_nil!.should be_a(Account)

        end


      end


    end

  end
end
