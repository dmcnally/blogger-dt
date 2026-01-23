require "test_helper"

class EventableTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
  end

  # Creation Event Tracking

  test "event is created when recording is created" do
    assert_equal 1, @recording.events.count
  end

  test "created event has action 'created' by default" do
    event = @recording.events.last

    assert_equal "created", event.action
  end

  test "created event subject references the recordable" do
    event = @recording.events.last

    assert_equal @article, event.subject
  end

  test "created event includes Current.person.id as person_id" do
    event = @recording.events.last

    assert_equal Current.person.id, event.person_id
  end

  test "created event person references Current.person" do
    event = @recording.events.last

    assert_equal Current.person, event.person
  end

  # Update Event Tracking

  test "event is created when recordable changes" do
    new_article = Article.new(title: "New Article", body: "New body")
    @recording.update!(recordable: new_article)

    assert_equal 2, @recording.events.count
  end

  test "updated event has action 'updated' by default" do
    new_article = Article.new(title: "New Article", body: "New body")
    @recording.update!(recordable: new_article)
    event = @recording.events.last

    assert_equal "updated", event.action
  end

  test "updated event tracks previous subject type and id" do
    original_article = @article
    new_article = Article.new(title: "New Article", body: "New body")
    @recording.update!(recordable: new_article)
    event = @recording.events.last

    assert_equal "Article", event.subject_previous_type
    assert_equal original_article.id, event.subject_previous_id
  end

  test "updated event subject references the new recordable" do
    new_article = Article.new(title: "New Article", body: "New body")
    @recording.update!(recordable: new_article)
    event = @recording.events.last

    assert_equal new_article, event.subject
  end

  test "no event created when recordable does not change" do
    initial_event_count = @recording.events.count

    # Touch the recording without changing recordable
    @recording.touch

    assert_equal initial_event_count, @recording.events.count
  end

  # Creator Method

  test "creator returns the person who created the record" do
    creator = @recording.creator

    assert_equal Current.person, creator
  end

  test "creator returns the person from the created event" do
    # Verify creator matches the person on the 'created' event specifically
    created_event = @recording.events.find_by(action: "created")

    assert_equal created_event.person, @recording.creator
  end
end
