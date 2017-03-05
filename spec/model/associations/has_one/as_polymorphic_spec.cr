require "../../database_preparation/db_helper"



module Associations
  module HasOne

    db_helper = DBHelper.instance

    describe "Plain" do

      describe "#relation" do

        it "should query dependent and assign dependent to #relation" do

          db_helper.fetch_post_text.post_node.not_nil!.should be_a(
            PostNode
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model" do

          db_helper.fetch_post_text.post_node(load: false).should be_nil
        end

      end

      describe "#realation(yield_repository: true, &block)" do

        it "returns repository#where : QueryBuilder of related model" do

          db_helper.fetch_post_text.post_node(yield_repository: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Where(Shepherd::Database::DefaultConnection, PostNode))
            repo.execute[0]?
          end
        end

        it "when #execute called on repository returned value should be assigned to #relation" do

          post_text = db_helper.fetch_post_text
          post_text.post_node(yield_repository: true) do |repo|
            repo.execute[0].not_nil!
          end
          post_text.post_node(load: false).not_nil!.should be_a(PostNode)
        end

      end


      describe "RELATION JOIN #repository#where.inner_join(&.relation)" do

        it "should validly join related model" do


          post_text = PostText.repository
            .inner_join(&.post_node)
            .where(PostNode, {"node_type", :eq, "PostText"})
            .execute[0]
            .not_nil!

          post_text.post_node.not_nil!.node_type.should eq("PostText")

        end

      end

      describe "RELATION EAGER LOADING #repository#eager_load(&.relation)" do

        it "should eagerly load related models" do


          post_text = PostText.repository
            .where(PostText, {"content", :eq, "post text"})
            .eager_load(&.post_node)
            .execute[0]
            .not_nil!

          post_text.post_node(load: false).not_nil!.should be_a(PostNode)

        end


      end


    end

  end
end
