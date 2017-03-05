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

      describe "#relations(load: false)" do

        it "should not load related model and return property" do

          db_helper.fetch_account.user(load: false).should be_nil
        end

      end

      describe "#realations(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do

          db_helper.fetch_account.user(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, User))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relations" do

          account = db_helper.fetch_account
          account.user(yield_repository: true) do |repo|
            repo.execute[0]?
          end
          account.user(load: false).not_nil!.should be_a(User)
        end

      end


      describe "RELATION JOIN #repository#where.inner_join(&.relations)" do

        it "should validly join related model" do


          Account.repository
            .inner_join(&.user)
            .where(User, {"name", :eq, "joe"})
            .execute[0]
            .not_nil!
            .should be_a(Account)

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relations)" do

        it "should eagerly load related models" do


          account = Account.repository
                  .where(Account, {"name", :eq, "account"})
                  .eager_load(&.user)
                  .execute[0].not_nil!

          account.user(load: false).not_nil!.should be_a(User)

        end


      end


    end

  end
end
