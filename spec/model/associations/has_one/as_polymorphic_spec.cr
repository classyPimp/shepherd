require "../../database_preparation/db_helper"



module Associations
  module HasOne

    db_helper = DBHelper.instance

    describe "has_one (as polymorphic)" do

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

      describe "#realation(yield_repo: true, &block)" do

        it "returns repo#where : QueryBuilder of related model" do

          db_helper.fetch_post_text.post_node(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, PostNode))
            repo.get
          end
        end

        it "when #get called on repo returned value should be assigned to #relation" do

          post_text = db_helper.fetch_post_text
          post_text.post_node(yield_repo: true) do |repo|
            repo.get.not_nil!
          end
          post_text.post_node(load: false).not_nil!.should be_a(PostNode)
        end

      end


      describe "RELATION JOIN #repo#where.inner_join(&.relation)" do

        it "should validly join related model" do


          post_text = PostText.repo
            .inner_join(&.post_node)
            .where(PostNode, {"node_type", :eq, "PostText"})
            .get
            .not_nil!

          post_text.post_node.not_nil!.node_type.should eq("PostText")

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relation)" do

        it "should eagerly load related models" do


          post_text = PostText.repo
            .where(PostText, {"content", :eq, "post text"})
            .eager_load(&.post_node)
            .get
            .not_nil!

          post_text.post_node(load: false).not_nil!.should be_a(PostNode)

        end


      end


    end

  end
end
