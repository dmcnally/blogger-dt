require "test_helper"

class DiscardableTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
  end

  # Scopes

  test "kept scope returns non-discarded recordings" do
    discarded_article = Article.new(title: "Discarded", body: "Body")
    discarded_recording = Recording.create!(recordable: discarded_article)
    discarded_recording.discard!

    kept = Recording.kept
    assert_includes kept, @recording
    refute_includes kept, discarded_recording
  end

  test "discarded scope returns discarded recordings" do
    @recording.discard!

    discarded = Recording.discarded
    assert_includes discarded, @recording
  end

  # Predicates

  test "discarded? returns false for non-discarded recording" do
    refute @recording.discarded?
  end

  test "discarded? returns true for discarded recording" do
    @recording.discard!
    assert @recording.discarded?
  end

  test "kept? returns true for non-discarded recording" do
    assert @recording.kept?
  end

  test "kept? returns false for discarded recording" do
    @recording.discard!
    refute @recording.kept?
  end

  # Discard behavior

  test "discard! sets discarded_at" do
    assert_nil @recording.discarded_at

    @recording.discard!

    assert_not_nil @recording.discarded_at
  end

  test "discard! creates a discarded event" do
    @recording.discard!

    event = @recording.events.find_by(action: "discarded")
    assert event.present?
    assert_equal @article, event.subject
  end

  test "discard! is idempotent" do
    @recording.discard!
    first_discarded_at = @recording.discarded_at
    event_count = @recording.events.count

    @recording.discard!

    assert_equal first_discarded_at, @recording.discarded_at
    assert_equal event_count, @recording.events.count
  end

  test "discard! calls recordable before_discard callback" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    @recording.discard!

    assert comment_recording.reload.discarded?
  end

  # Cascade behavior

  test "discarding article discards children" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    Tag.named("ruby")
    @recording.tag!("ruby")
    tag_recording = @recording.tag_recordings.first

    @recording.publish!
    publication_recording = @recording.publication_recording

    @recording.discard!

    assert comment_recording.reload.discarded?
    assert tag_recording.reload.discarded?
    assert publication_recording.reload.discarded?
  end

  test "discarding comment discards child comments" do
    comment = Comment.new(body: "Parent comment")
    comment_recording = @recording.children.create!(recordable: comment)

    reply = Comment.new(body: "Reply comment")
    reply_recording = comment_recording.children.create!(recordable: reply)

    comment_recording.discard!

    assert reply_recording.reload.discarded?
  end

  test "discarding tag does not cascade" do
    Tag.named("ruby")
    @recording.tag!("ruby")
    tag_recording = @recording.tag_recordings.first

    tag_recording.discard!

    refute @recording.reload.discarded?
  end

  # Event immutability

  test "events are preserved after discard" do
    event_count = @recording.events.count

    @recording.discard!

    # Original events plus the discarded event
    assert_equal event_count + 1, @recording.events.count
  end

  test "cannot hard delete recording with events" do
    assert_raises ActiveRecord::DeleteRestrictionError do
      @recording.destroy!
    end
  end
end
