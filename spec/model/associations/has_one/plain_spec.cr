require "../../database_preparation/db_helper_hm_ho_bt_plain"



module Associations
  module HasOne

    describe "Plain" do

      describe "#relation" do

        it "should query dependent and assign dependent to #relation" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations
          db_helper.get_user.account.not_nil!.should be_a(
            Account
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations
          db_helper.get_user.account(load: false).should be_nil
        end

      end

      describe "#realation(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations
          db_helper.get_user.account(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, Account))
          end
        end

        it "when #execute called on repository returned value should be assigned to #relation" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations
          db_helper.get_user.account(yield_repository: true) do |repo|
            repo.execute[0].not_nil!
          end
          db_helper.get_user.account(load: false).not_nil!.should be_a(Account)
        end

      end


      describe "RELATION JOIN #repository#where.inner_join(&.relation)" do

        it "should validly join related model" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations

          user = User.repository
            .inner_join(&.account)
            .where(Account, {"name", :eq, "account"})
            .execute[0]
            .not_nil!

          user.account.not_nil!.name.should eq("account")

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relation)" do

        it "should eagerly load related models" do
          db_helper = DBHelperHmHoBtPLain.new.prepare_for_plain_relations

          user = User.repository
                  .where(User, {"name", :eq, "joe"})
                  .eager_load(&.account)
                  .execute[0].not_nil!

          user.account(load: false).not_nil!.should be_a(Account)

        end


      end


    end

  end
end
