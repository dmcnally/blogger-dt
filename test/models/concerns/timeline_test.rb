require "test_helper"

class TimelineTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @root_recording = Recording.create!(recordable: @article)
  end

  # timeline_events

  test "timeline_events returns events from self" do
    events = @root_recording.timeline_events

    assert_equal 1, events.count
    assert_equal "created", events.first.action
  end

  test "timeline_events returns events from descendants" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    events = @root_recording.timeline_events

    assert_equal 2, events.count
    assert_includes events.map(&:eventable), @root_recording
    assert_includes events.map(&:eventable), child_recording
  end

  test "timeline_events orders by created_at ascending" do
    comment1 = Comment.new(body: "First comment")
    child1 = @root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Second comment")
    child2 = @root_recording.children.create!(recordable: comment2)

    events = @root_recording.timeline_events

    assert_equal 3, events.count
    assert_equal events.to_a, events.order(created_at: :asc).to_a
  end

  test "timeline_events includes nested descendant events" do
    comment1 = Comment.new(body: "First comment")
    child1 = @root_recording.children.create!(recordable: comment1)

    comment2 = Comment.new(body: "Nested comment")
    grandchild = child1.children.create!(recordable: comment2)

    events = @root_recording.timeline_events

    assert_equal 3, events.count
    assert_includes events.map(&:eventable), grandchild
  end

  # ancestor_recording

  test "ancestor_recording finds ancestor with specified recordable type" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    ancestor = child_recording.ancestor_recording(Article)

    assert_equal @root_recording, ancestor
  end

  test "ancestor_recording returns nil when no matching ancestor" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)

    ancestor = child_recording.ancestor_recording(PersonCard)

    assert_nil ancestor
  end

  test "ancestor_recording returns nil for root recording" do
    ancestor = @root_recording.ancestor_recording(Article)

    assert_nil ancestor
  end

  # subject_at

  test "subject_at returns the subject at a given event time" do
    event = @root_recording.events.first

    subject = @root_recording.subject_at(event)

    assert_equal @article, subject
  end

  test "subject_at returns latest subject before or at event time" do
    original_article = @article
    new_article = Article.new(title: "Updated Article", body: "Updated body")
    @root_recording.update!(recordable: new_article)

    first_event = @root_recording.events.order(:created_at).first
    latest_event = @root_recording.events.order(:created_at).last

    assert_equal original_article, @root_recording.subject_at(first_event)
    assert_equal new_article, @root_recording.subject_at(latest_event)
  end

  # ancestor_at

  test "ancestor_at combines ancestor lookup with subject_at" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)
    event = child_recording.events.first

    ancestor_subject = child_recording.ancestor_at(Article, event)

    assert_equal @article, ancestor_subject
  end

  test "ancestor_at returns nil when no matching ancestor" do
    comment = Comment.new(body: "Test comment")
    child_recording = @root_recording.children.create!(recordable: comment)
    event = child_recording.events.first

    ancestor_subject = child_recording.ancestor_at(PersonCard, event)

    assert_nil ancestor_subject
  end
end
