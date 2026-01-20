require "test_helper"

class CommenterTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @article_recording = Recording.create!(recordable: @article)
  end

  test "comments returns Comment children for commentable recordables" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    comments = @article_recording.comments

    assert_equal 1, comments.count
    assert_includes comments, comment_recording
  end

  test "comments returns empty relation when no comments exist" do
    comments = @article_recording.comments

    assert_empty comments
    assert_kind_of ActiveRecord::Relation, comments
  end

  test "comments returns empty relation for non-commentable recordables" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    # Comment is not commentable, so it should return an empty relation
    comments = comment_recording.comments

    assert_empty comments
    assert_kind_of ActiveRecord::Relation, comments
  end

  test "comments only returns children with recordable_type Comment" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    # Also add a publication state as a child
    @article_recording.publish!

    comments = @article_recording.comments

    assert_equal 1, comments.count
    assert_includes comments, comment_recording
  end

  test "comments does not include nested comment recordings" do
    comment1 = Comment.new(body: "First comment")
    comment1_recording = @article_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Nested comment")
    comment2_recording = comment1_recording.children.create!(recordable: comment2)

    comments = @article_recording.comments

    assert_equal 1, comments.count
    assert_includes comments, comment1_recording
    refute_includes comments, comment2_recording
  end
end
