require "test_helper"

class PublisherTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
  end

  test "published? returns false when no publication exists" do
    refute @recording.published?
  end

  test "published? returns true when publication exists" do
    @recording.publish!
    assert @recording.published?
  end

  test "publish! creates publication" do
    assert_difference -> { Publication.count }, 1 do
      @recording.publish!
    end
    assert @recording.publication.present?
  end

  test "publish! is idempotent" do
    @recording.publish!
    assert_no_difference -> { Publication.count } do
      @recording.publish!
    end
  end

  test "unpublish! destroys publication" do
    @recording.publish!
    assert_difference -> { Publication.count }, -1 do
      @recording.unpublish!
    end
    refute @recording.published?
  end

  test "unpublish! does nothing when not published" do
    assert_no_difference -> { Publication.count } do
      @recording.unpublish!
    end
  end

  test "publish! does nothing when recordable is not publishable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @recording.children.create!(recordable: comment)

    assert_no_difference -> { Publication.count } do
      comment_recording.publish!
    end
    refute comment_recording.published?
  end

  test "publish! creates event with published action on recording" do
    @recording.publish!
    event = @recording.events.find_by(action: "published")

    assert event.present?
    assert_equal @article, event.subject
  end

  test "unpublish! creates event with unpublished action on recording" do
    @recording.publish!
    @recording.unpublish!
    event = @recording.events.find_by(action: "unpublished")

    assert event.present?
    assert_equal @article, event.subject
  end

  test "toggling publish state creates events with correct actions" do
    @recording.publish!
    @recording.unpublish!
    @recording.publish!

    actions = @recording.events.where(action: %w[published unpublished]).order(:created_at).pluck(:action)

    assert_equal %w[published unpublished published], actions
  end

  test "publication belongs to recording" do
    @recording.publish!

    assert_equal @recording, @recording.publication.recording
  end

  test "published scope returns only published recordings" do
    another_article = Article.new(title: "Another Article", body: "Another body")
    another_recording = Recording.create!(recordable: another_article)

    @recording.publish!

    published_recordings = Recording.published

    assert_includes published_recordings, @recording
    refute_includes published_recordings, another_recording
  end

  test "published scope returns empty when none are published" do
    assert_empty Recording.published
  end

  test "unpublished scope returns only unpublished recordings" do
    another_article = Article.new(title: "Another Article", body: "Another body")
    another_recording = Recording.create!(recordable: another_article)

    @recording.publish!

    unpublished_recordings = Recording.unpublished

    refute_includes unpublished_recordings, @recording
    assert_includes unpublished_recordings, another_recording
  end

  test "unpublished scope excludes published recordings" do
    @recording.publish!

    refute_includes Recording.unpublished, @recording
  end
end
