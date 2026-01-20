require "test_helper"

class Tag::StateTest < ActiveSupport::TestCase
  setup do
    @tag = Tag.named("ruby")
    @state = @tag.state
  end

  test "enable! sets available to true" do
    @state.update!(available: false)
    refute @state.available?

    @state.enable!

    assert @state.available?
    assert @state.reload.available
  end

  test "disable! sets available to false" do
    assert @state.available?

    @state.disable!

    refute @state.available?
    refute @state.reload.available
  end

  test "available? returns correct boolean" do
    assert @state.available?

    @state.update!(available: false)
    refute @state.available?

    @state.update!(available: true)
    assert @state.available?
  end

  test "state belongs to tag" do
    assert_equal @tag, @state.tag
  end
end
