require "test_helper"

class BucketableTest < ActiveSupport::TestCase
  setup do
    @bucket_a = Bucket.create!(name: "Bucket A")
    @bucket_b = Bucket.create!(name: "Bucket B")
  end

  # set_bucket

  test "sets bucket from Current.bucket when no parent" do
    Current.bucket = @bucket_a

    article = Article.new(title: "Test Article", body: "Test body")
    recording = Recording.create!(recordable: article)

    assert_equal @bucket_a, recording.bucket
  end

  test "raises error when Current.bucket is not set and no parent" do
    Current.bucket = nil

    article = Article.new(title: "Test Article", body: "Test body")

    assert_raises(RuntimeError, match: /Bucket must be set/) do
      Recording.create!(recordable: article)
    end
  end

  # parent inheritance

  test "child recording inherits parent bucket" do
    Current.bucket = @bucket_a
    article = Article.new(title: "Test Article", body: "Test body")
    parent_recording = Recording.create!(recordable: article)

    # Change Current.bucket to simulate misconfiguration
    Current.bucket = @bucket_b

    comment = Comment.new(body: "Test comment")
    child_recording = parent_recording.children.build(recordable: comment)
    child_recording.save!

    assert_equal parent_recording.bucket, child_recording.bucket,
      "Child should inherit parent's bucket, not Current.bucket"
  end

  test "child inherits bucket even when Current.bucket is nil" do
    Current.bucket = @bucket_a
    article = Article.new(title: "Test Article", body: "Test body")
    parent_recording = Recording.create!(recordable: article)

    # Set Current.bucket to nil
    Current.bucket = nil

    comment = Comment.new(body: "Test comment")
    child_recording = parent_recording.children.build(recordable: comment)
    child_recording.save!

    assert_equal parent_recording.bucket, child_recording.bucket
  end

  test "deeply nested children all inherit root bucket" do
    Current.bucket = @bucket_a
    article = Article.new(title: "Test Article", body: "Test body")
    root_recording = Recording.create!(recordable: article)

    # Change bucket
    Current.bucket = @bucket_b

    comment1 = Comment.new(body: "First comment")
    child1 = root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Reply to first comment")
    child2 = child1.children.create!(recordable: comment2)

    assert_equal @bucket_a, child1.bucket
    assert_equal @bucket_a, child2.bucket
  end

  # validation

  test "cannot explicitly set bucket different from parent" do
    Current.bucket = @bucket_a
    article = Article.new(title: "Test Article", body: "Test body")
    parent_recording = Recording.create!(recordable: article)

    comment = Comment.new(body: "Test comment")
    child_recording = parent_recording.children.build(
      recordable: comment,
      bucket: @bucket_b  # Explicitly trying to set different bucket
    )

    assert_not child_recording.valid?
    assert_includes child_recording.errors[:bucket], "must match parent's bucket"
  end

  # explicit bucket setting

  test "allows explicit bucket when it matches parent" do
    Current.bucket = @bucket_a
    article = Article.new(title: "Test Article", body: "Test body")
    parent_recording = Recording.create!(recordable: article)

    comment = Comment.new(body: "Test comment")
    child_recording = parent_recording.children.build(
      recordable: comment,
      bucket: @bucket_a  # Same as parent
    )

    assert child_recording.valid?
    child_recording.save!
    assert_equal @bucket_a, child_recording.bucket
  end
end
