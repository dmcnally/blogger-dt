require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "Tag.named creates tag with state" do
    tag = Tag.named("ruby")

    assert tag.persisted?
    assert_equal "ruby", tag.name
    assert tag.state.present?
    assert tag.state.available?
  end

  test "Tag.named reuses existing tag" do
    tag1 = Tag.named("ruby")
    tag2 = Tag.named("ruby")

    assert_equal tag1.id, tag2.id
    assert_equal 1, Tag.where(name: "ruby").count
  end

  test "Tag.named normalizes name to lowercase" do
    tag = Tag.named("RUBY")

    assert_equal "ruby", tag.name
  end

  test "Tag.named strips whitespace" do
    tag = Tag.named("  ruby  ")

    assert_equal "ruby", tag.name
  end

  test "Tag.available scope returns only available tags" do
    available_tag = Tag.named("ruby")
    unavailable_tag = Tag.named("disabled")
    unavailable_tag.state.disable!

    available_tags = Tag.available

    assert_includes available_tags, available_tag
    refute_includes available_tags, unavailable_tag
  end

  test "available? delegates to state" do
    tag = Tag.named("ruby")

    assert tag.available?

    tag.state.disable!
    refute tag.available?

    tag.state.enable!
    assert tag.available?
  end

  test "available? returns false when state is nil" do
    tag = Tag.create!(name: "no-state")

    refute tag.available?
  end

  test "name must be unique" do
    Tag.named("ruby")

    assert_raises(ActiveRecord::RecordInvalid) do
      Tag.create!(name: "ruby")
    end
  end

  test "name must be present" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Tag.create!(name: "")
    end
  end
end
