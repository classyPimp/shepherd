require "../../database_preparation/db_helper"



module Associations
  module HasMany

    db_helper = DBHelper.instance
    describe "has_many (as polymorphic)" do

      describe "#relations" do

        it "should query dependent and return collection of dependents" do
          db_helper.fetch_post_text.post_nodes.should be_a(
            Shepherd::Model::Collection(PostNode)
          )
        end

        it "returned collection's first index value should be related model" do

          db_helper.fetch_post_text.post_nodes[-1].not_nil!.should be_a(
            PostNode
          )
        end

        it "queries and returns all realted models" do

          size = db_helper.fetch_post_text.post_nodes.size
          size.should eq(1)

        end

      end

      describe "#relations(load: false)" do

        it "should return collection of related values anyway" do

          db_helper.fetch_post_text.post_nodes(load: false).should be_a(
            Shepherd::Model::Collection(PostNode)
          )
        end

        it "should not load related model" do

          db_helper.fetch_post_text.post_nodes(load: false)[0]?.should be_a(
            Nil
          )
        end

      end

      describe "#realations(yield_repo: true, &block)" do

        it "returns repo#where : QueryBuilder of related model" do

          db_helper.fetch_post_text.post_nodes(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, PostNode))
          end
        end

        it "when #list called on repo returned value should be assigned to #relations" do

          post_text = db_helper.fetch_post_text
          post_text.post_nodes(yield_repo: true) do |repo|
            repo.list
          end

          post_text.post_nodes(load: false)[0].not_nil!.should be_a(PostNode)
        end

      end

      describe "RELATION JOIN #repo#where.inner_join(&.relations)" do

        it "should validly join related model" do


          PostText.repo
            .inner_join(&.post_nodes)
            .where(PostNode, {"node_type", :eq, "PostText"})
            .get
            .not_nil!
            .should be_a(PostText)

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relations)" do

        it "should eagerly load related models" do


          post_text = PostText.repo
            .where(PostText, {"content", :eq, "post text"})
            .eager_load(&.post_nodes)
            .get.not_nil!

          post_text.post_nodes(load: false)[0].not_nil!.should be_a(PostNode)

        end


      end


    end

  end
end
