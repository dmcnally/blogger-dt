require "test_helper"

class PublisherTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
  end

  test "published? returns false when no publication recording exists" do
    refute @recording.published?
  end

  test "publish! creates publication recording with published state" do
    @recording.publish!
    assert @recording.published?
    assert_equal PublicationState::PUBLISHED, @recording.publication_recording.recordable.state
  end

  test "unpublish! creates publication recording with notPublished state when none exists" do
    @recording.unpublish!
    refute @recording.published?
    assert_equal PublicationState::NOT_PUBLISHED, @recording.publication_recording.recordable.state
  end

  test "publish! updates existing publication recording to published" do
    @recording.unpublish!
    refute @recording.published?

    @recording.publish!
    assert @recording.published?

    # Should still only have one publication recording
    assert_equal 1, @recording.children.where(recordable_type: "PublicationState").count
  end

  test "unpublish! updates existing publication recording to notPublished" do
    @recording.publish!
    assert @recording.published?

    @recording.unpublish!
    refute @recording.published?

    # Should still only have one publication recording
    assert_equal 1, @recording.children.where(recordable_type: "PublicationState").count
  end

  test "publish! does nothing when recordable is not publishable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    comment_recording.publish!
    assert_nil comment_recording.publication_recording
    refute comment_recording.published?
  end

  test "publication_recording returns nil when recordable is not publishable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    assert_nil comment_recording.publication_recording
  end

  test "publication_recording.recordable returns the PublicationState" do
    @recording.publish!
    assert_equal PublicationState.published, @recording.publication_recording.recordable
  end

  test "publish! creates event with published action" do
    @recording.publish!
    publication_recording = @recording.publication_recording
    event = publication_recording.events.last

    assert_equal "published", event.action
    assert_equal PublicationState.published, event.subject
  end

  test "unpublish! creates event with unpublished action" do
    @recording.unpublish!
    publication_recording = @recording.publication_recording
    event = publication_recording.events.last

    assert_equal "unpublished", event.action
    assert_equal PublicationState.not_published, event.subject
  end

  test "toggling publish state creates events with correct actions" do
    @recording.publish!
    @recording.unpublish!
    @recording.publish!

    publication_recording = @recording.publication_recording
    actions = publication_recording.events.order(:created_at).pluck(:action)

    assert_equal %w[published unpublished published], actions
  end
end
