require "test_helper"

class TaggerTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
  end

  test "tag! adds a tag as a child recording when tag is available" do
    Tag.named("ruby") # Creates tag with state available=true

    @recording.tag!("ruby")

    assert @recording.tagged?("ruby")
    assert_equal 1, @recording.tag_recordings.count
    assert_equal "ruby", @recording.tags.first.name
  end

  test "tag! does nothing if tag is unavailable" do
    tag = Tag.named("disabled")
    tag.state.disable!

    @recording.tag!("disabled")

    refute @recording.tagged?("disabled")
    assert_equal 0, @recording.tag_recordings.count
  end

  test "untag! removes the tag recording" do
    Tag.named("ruby")
    @recording.tag!("ruby")
    assert @recording.tagged?("ruby")

    @recording.untag!("ruby")

    refute @recording.tagged?("ruby")
    assert_equal 0, @recording.tag_recordings.count
  end

  test "tagged? returns correct boolean" do
    Tag.named("ruby")
    refute @recording.tagged?("ruby")

    @recording.tag!("ruby")
    assert @recording.tagged?("ruby")
  end

  test "tags returns the Tag records" do
    Tag.named("ruby")
    Tag.named("rails")
    @recording.tag!("ruby")
    @recording.tag!("rails")

    tags = @recording.tags
    assert_equal 2, tags.count
    assert_includes tags.pluck(:name), "ruby"
    assert_includes tags.pluck(:name), "rails"
  end

  test "available_tags filters to only available tags" do
    Tag.named("ruby")
    rails_tag = Tag.named("rails")
    @recording.tag!("ruby")
    @recording.tag!("rails")

    # Disable rails tag after it was applied
    rails_tag.state.disable!

    available = @recording.available_tags
    assert_equal 1, available.count
    assert_equal "ruby", available.first.name
  end

  test "tagging is a no-op for non-taggable recordables" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)
    Tag.named("ruby")

    comment_recording.tag!("ruby")

    refute comment_recording.tagged?("ruby")
    assert_equal 0, comment_recording.tag_recordings.count
  end

  test "duplicate tags are not created" do
    Tag.named("ruby")
    @recording.tag!("ruby")
    @recording.tag!("ruby")

    assert_equal 1, @recording.tag_recordings.count
  end

  test "Tag recordable is shared across articles" do
    article2 = Article.new(title: "Second Article", body: "Test body")
    recording2 = Recording.create!(recordable: article2)

    Tag.named("ruby")
    @recording.tag!("ruby")
    recording2.tag!("ruby")

    # Both recordings share the same Tag recordable
    assert_equal @recording.tags.first.id, recording2.tags.first.id

    # But they have separate child recordings
    assert_equal 1, @recording.tag_recordings.count
    assert_equal 1, recording2.tag_recordings.count
  end

  test "tag! creates event when tagging" do
    Tag.named("ruby")
    @recording.tag!("ruby")

    tag_recording = @recording.tag_recordings.first
    event = tag_recording.events.last

    assert_equal "created", event.action
    assert_equal Tag.find_by(name: "ruby"), event.subject
  end

  test "untag! destroys the tag recording" do
    Tag.named("ruby")
    @recording.tag!("ruby")
    tag_recording_id = @recording.tag_recordings.first.id

    @recording.untag!("ruby")

    refute Recording.exists?(tag_recording_id)
  end

  test "tag_recordings returns empty relation for non-taggable recordables" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    assert_equal 0, comment_recording.tag_recordings.count
  end

  test "tag! normalizes tag name to lowercase" do
    Tag.named("Ruby")
    @recording.tag!("RUBY")

    assert @recording.tagged?("ruby")
    assert_equal "ruby", @recording.tags.first.name
  end

  test "tag! strips whitespace from tag name" do
    Tag.named("  ruby  ")
    @recording.tag!(" ruby ")

    assert @recording.tagged?("ruby")
    assert_equal "ruby", @recording.tags.first.name
  end
end
