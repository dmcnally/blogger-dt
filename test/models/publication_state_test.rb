require "test_helper"

class PublicationStateTest < ActiveSupport::TestCase
  test "published singleton returns publication state with published state" do
    publication_state = PublicationState.published
    assert_equal PublicationState::PUBLISHED, publication_state.state
    assert publication_state.published?
  end

  test "not_published singleton returns publication state with notPublished state" do
    publication_state = PublicationState.not_published
    assert_equal PublicationState::NOT_PUBLISHED, publication_state.state
    refute publication_state.published?
  end

  test "published singleton is idempotent" do
    first = PublicationState.published
    second = PublicationState.published
    assert_equal first.id, second.id
  end

  test "not_published singleton is idempotent" do
    first = PublicationState.not_published
    second = PublicationState.not_published
    assert_equal first.id, second.id
  end

  test "state must be valid" do
    publication_state = PublicationState.new(state: "invalid")
    refute publication_state.valid?
    assert_includes publication_state.errors[:state], "is not included in the list"
  end

  test "state must be present" do
    publication_state = PublicationState.new(state: nil)
    refute publication_state.valid?
    assert_includes publication_state.errors[:state], "can't be blank"
  end

  test "state must be unique" do
    PublicationState.published # create first
    duplicate = PublicationState.new(state: PublicationState::PUBLISHED)
    refute duplicate.valid?
    assert_includes duplicate.errors[:state], "has already been taken"
  end

  test "event_action returns published when state is published" do
    publication_state = PublicationState.published
    assert_equal "published", publication_state.event_action
  end

  test "event_action returns unpublished when state is notPublished" do
    publication_state = PublicationState.not_published
    assert_equal "unpublished", publication_state.event_action
  end
end
