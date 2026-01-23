require "test_helper"

class TreeTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @root_recording = Recording.create!(recordable: @article)
  end

  # root?

  test "root? returns true when parent_id is nil" do
    assert @root_recording.root?
  end

  test "root? returns false when parent exists" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    refute child_recording.root?
  end

  # root

  test "root returns self when recording is root" do
    assert_equal @root_recording, @root_recording.root
  end

  test "root traverses up to find the root" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    assert_equal @root_recording, child_recording.root
  end

  test "root traverses multiple levels to find root" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @root_recording.children.create!(recordable: comment)

    reply = Comment.new(body: "Reply comment")
    reply_recording = comment_recording.children.create!(recordable: reply)

    assert_equal @root_recording, comment_recording.root
    assert_equal @root_recording, reply_recording.root
  end

  # ancestors

  test "ancestors returns empty array for root" do
    assert_equal [], @root_recording.ancestors
  end

  test "ancestors returns parent chain for nested recording" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    assert_equal [ @root_recording ], child_recording.ancestors
  end

  test "ancestors returns full chain for deeply nested recording" do
    comment1 = Comment.new(body: "First comment")
    child1 = @root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Second comment")
    child2 = child1.children.create!(recordable: comment2)

    assert_equal [ child1, @root_recording ], child2.ancestors
  end

  # descendants

  test "descendants returns empty array when no children" do
    assert_equal [], @root_recording.descendants
  end

  test "descendants returns all children" do
    comment1 = Comment.new(body: "First comment")
    child1 = @root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Second comment")
    child2 = @root_recording.children.create!(recordable: comment2)

    descendants = @root_recording.descendants
    assert_includes descendants, child1
    assert_includes descendants, child2
    assert_equal 2, descendants.size
  end

  test "descendants returns all nested children recursively" do
    comment1 = Comment.new(body: "First comment")
    child1 = @root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Second comment")
    grandchild = child1.children.create!(recordable: comment2)

    descendants = @root_recording.descendants
    assert_includes descendants, child1
    assert_includes descendants, grandchild
    assert_equal 2, descendants.size
  end
end
