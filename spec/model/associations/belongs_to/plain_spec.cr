require "../../database_preparation/db_helper_hm_ho_bt_plain"



module Associations
  module BelongsTo

    helper = DBHelperHmHoBtPLain.new

    describe "Plain" do

      describe "#relation" do

        it "should query dependent and return dependent" do
          db_helper = helper.prepare_for_plain_relations
          db_helper.get_account.user.not_nil!.should be_a(
            User
          )
        end

      end

      describe "#relations(load: false)" do

        it "should not load related model" do
          db_helper = helper.prepare_for_plain_relations
          db_helper.get_account.user(load: false).should be_nil
        end

      end

      describe "#realations(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do
          db_helper = helper.prepare_for_plain_relations
          db_helper.get_account.user(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, User))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relations" do
          db_helper = helper.prepare_for_plain_relations
          db_helper.get_account.user(yield_repository: true) do |repo|
            repo.execute[0]?
          end
          db_helper.get_account.user(load: false).not_nil!.should be_a(User)
        end

      end


      describe "RELATION JOIN #repository#where.inner_join(&.relations)" do

        it "should validly join related model" do
          db_helper = helper.prepare_for_plain_relations

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
          db_helper = helper.prepare_for_plain_relations

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
