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

      describe "#realations(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do

          db_helper.fetch_user.accounts(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relations" do

          user = db_helper.fetch_user
          user.accounts(yield_repository: true) do |repo|
            repo.execute
          end

          user.accounts(load: false)[0].not_nil!.should be_a(Account)
        end

      end

      describe "RELATION JOIN #repository#where.inner_join(&.relations)" do

        it "should validly join related model" do


          User.repository
            .inner_join(&.accounts)
            .where(Account, {"name", :eq, "account"})
            .execute[0]
            .not_nil!
            .should be_a(User)

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relations)" do

        it "should eagerly load related models" do


          user = User.repository
                  .where(User, {"name", :eq, "joe"})
                  .eager_load(&.accounts)
                  .execute[0].not_nil!

          user.accounts(load: false)[0].not_nil!.should be_a(Account)

        end


      end


    end

  end
end
