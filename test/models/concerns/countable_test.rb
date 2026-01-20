require "test_helper"

class CountableTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @article_recording = Recording.create!(recordable: @article)
  end

  test "countable? returns false by default for non-countable types" do
    refute Article.countable?
  end

  test "Comment.countable? returns true" do
    assert Comment.countable?
  end

  test "Comment.counter_name returns 'comments'" do
    assert_equal "comments", Comment.counter_name
  end

  test "Comment.count_for returns count of comment children" do
    # No comments yet
    assert_equal 0, Comment.count_for(@article_recording)

    # Add comments
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 1"))
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 2"))

    assert_equal 2, Comment.count_for(@article_recording)
  end
end
