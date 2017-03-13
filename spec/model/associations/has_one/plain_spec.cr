require "../../database_preparation/db_helper"



module Associations
  module HasOne

    db_helper =  DBHelper.instance

    describe "has_one (plain)" do

      describe "#relation" do

        it "should query dependent and assign dependent to #relation" do

          db_helper.fetch_user.account.not_nil!.should be_a(
            Account
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model" do

          db_helper.fetch_user.account(load: false).should be_nil
        end

      end

      describe "#realation(yield_repo: true, &block)" do

        it "returns repo#where : QueryBuilder of related model" do

          db_helper.fetch_user.account(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #get called on repo returned value should be assigned to #relation" do

          user = db_helper.fetch_user
          user.account(yield_repo: true) do |repo|
            repo.get.not_nil!
          end
          user.account(load: false).not_nil!.should be_a(Account)
        end

      end


      describe "RELATION JOIN #repo#where.inner_join(&.relation)" do

        it "should validly join related model" do


          user = User.repo
            .inner_join(&.account)
            .where(Account, {"name", :eq, "account"})
            .get
            .not_nil!

          user.account.not_nil!.name.should eq("account")

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relation)" do

        it "should eagerly load related models" do


          user = User.repo
                  .where(User, {"name", :eq, "joe"})
                  .eager_load(&.account)
                  .get.not_nil!

          user.account(load: false).not_nil!.should be_a(Account)

        end


      end


    end

  end
end
