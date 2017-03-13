require "../../database_preparation/db_helper"



module Associations
  module BelongsTo

    db_helper = DBHelper.instance

    describe "belongs_to (plain)" do

      describe "#relation" do

        it "should query dependent and assign it to property" do

          db_helper.fetch_account.user.not_nil!.should be_a(
            User
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model and return property" do

          db_helper.fetch_account.user(load: false).should be_nil
        end

      end

      describe "#realation(yield_repo: true, &block)" do

        it "returns repo#where : QueryBuilder of related model" do

          db_helper.fetch_account.user(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, User))
          end
        end

        it "when #get called on repo returned value should be assigned to #relation" do

          account = db_helper.fetch_account
          account.user(yield_repo: true) do |repo|
            repo.get
          end
          account.user(load: false).not_nil!.should be_a(User)
        end

      end


      describe "RELATION JOIN #repo#where.inner_join(&.relations)" do

        it "should validly join related model" do


          Account.repo
            .inner_join(&.user)
            .where(User, {"name", :eq, "joe"})
            .get
            .not_nil!
            .should be_a(Account)

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relations)" do

        it "should eagerly load related models" do


          account = Account.repo
                  .where(Account, {"name", :eq, "account"})
                  .eager_load(&.user)
                  .get.not_nil!

          account.user(load: false).not_nil!.should be_a(User)

        end


      end


    end

  end
end
