require "../../database_preparation/db_helper"



module Associations
  module BelongsTo

    db_helper = DBHelper.instance

    describe "belongs_to (polymorphic)" do

      describe "#relation" do

        it "should query dependent and return dependent with correct type" do

          db_helper.fetch_post_node_btp_post_image.node.not_nil!.should be_a(
            PostImage
          )

          db_helper.fetch_post_node_btp_post_text.node.not_nil!.should be_a(
            PostText
          )
        end

      end

      describe "#relation(load: false)" do

        it "should not load related model" do

          db_helper.fetch_post_node_btp_post_image.node(load: false).should be_nil
        end

      end

      describe "#realation(yield_repo: true, &block)" do

        it "returns #repo : Repository of related model for corresponding type" do

          db_helper.fetch_post_node_btp_post_image.node(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, PostImage))
          end

          db_helper.fetch_post_node_btp_post_text.node(yield_repo: true) do |repo|
            repo.should be_a(Shepherd::Model::QueryBuilder::Adapters::Postgres::Repository(Shepherd::Database::DefaultConnection, PostText))
          end

        end

        it "when #get called on repo returned value should be assigned to #relation" do

          post_node_btp_post_image = db_helper.fetch_post_node_btp_post_image
          post_node_btp_post_image.node(yield_repo: true) do |repo|
            repo.not_nil!.get
          end

          post_node_btp_post_image.node(load: false).not_nil!.should be_a(PostImage)

          post_node_btp_post_text = db_helper.fetch_post_node_btp_post_text
          post_node_btp_post_text.node(yield_repo: true) do |repo|
            repo.not_nil!.get
          end

          post_node_btp_post_text.node(load: false).not_nil!.should be_a(PostText)
        end

      end


      describe "RELATION JOIN #repo#where.inner_join(&.relation(poly_type_class))" do

        it "should validly join related model depending on &.relation_name(relation_class) " do


          PostNode.repo
            .inner_join(&.node(PostImage))
            .where(PostImage, {"content", :eq, "post image"})
            .get
            .not_nil!
            .should be_a(PostNode)

          PostNode.repo
            .inner_join(&.node(PostText))
            .where(PostText, {"content", :eq, "post text"})
            .get
            .not_nil!
            .should be_a(PostNode)

        end

      end

      describe "RELATION EAGER LOADING #repo#eager_load(&.relations)" do

        it "should eagerly load related models" do


          post_node = PostNode.repo
                  .where(PostNode, {"node_type", :eq, "PostImage"})
                  .eager_load(&.node)
                  .get.not_nil!

          post_node.node(load: false).not_nil!.should be_a(PostImage)

          post_node = PostNode.repo
                  .where(PostNode, {"node_type", :eq, "PostText"})
                  .eager_load(&.node)
                  .get.not_nil!

          post_node.node(load: false).not_nil!.should be_a(PostText)

        end

        it "block in it returns {...relation_stringified_names: relation's repo pairs}" do

          post_node = PostNode.repo
          .where(PostNode, {"node_type", :eq, "PostImage"})
          .eager_load(&.node.tap {|repo|
            #shouldnt raise TODO: write the type
            repo["PostImage"]
            repo["PostText"]
          })
          .get
        end

      end


    end

  end
end
