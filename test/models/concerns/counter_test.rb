require "test_helper"

class CounterTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @article_recording = Recording.create!(recordable: @article)
  end

  test "counter returns 0 when no cache exists" do
    assert_equal 0, @article_recording.counter(:comments)
  end

  test "increment_counter! creates and increments cache" do
    @article_recording.increment_counter!(:comments)
    assert_equal 1, @article_recording.counter(:comments)

    @article_recording.increment_counter!(:comments)
    assert_equal 2, @article_recording.counter(:comments)
  end

  test "decrement_counter! decrements cache" do
    @article_recording.increment_counter!(:comments)
    @article_recording.increment_counter!(:comments)
    assert_equal 2, @article_recording.counter(:comments)

    @article_recording.decrement_counter!(:comments)
    assert_equal 1, @article_recording.counter(:comments)
  end

  test "decrement_counter! does not go below zero" do
    @article_recording.increment_counter!(:comments)
    @article_recording.decrement_counter!(:comments)
    @article_recording.decrement_counter!(:comments)

    assert_equal 0, @article_recording.counter(:comments)
  end

  test "refresh_counter! sets correct count from query" do
    # Manually add comments without triggering callbacks
    Recording.skip_callback(:create, :after, :increment_parent_counter)
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 1"))
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 2"))
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 3"))
    Recording.set_callback(:create, :after, :increment_parent_counter)

    # Counter should be 0 since callbacks were skipped
    assert_equal 0, @article_recording.counter(:comments)

    # Refresh should fix it
    @article_recording.refresh_counter!(:comments)
    assert_equal 3, @article_recording.counter(:comments)
  end

  test "refresh_all_counters! refreshes all registered types" do
    # Manually add comments without triggering callbacks
    Recording.skip_callback(:create, :after, :increment_parent_counter)
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 1"))
    @article_recording.children.create!(recordable: Comment.new(body: "Comment 2"))
    Recording.set_callback(:create, :after, :increment_parent_counter)

    assert_equal 0, @article_recording.counter(:comments)

    @article_recording.refresh_all_counters!
    assert_equal 2, @article_recording.counter(:comments)
  end

  test "counter is incremented when comment recording is created" do
    assert_equal 0, @article_recording.counter(:comments)

    @article_recording.children.create!(recordable: Comment.new(body: "New comment"))

    assert_equal 1, @article_recording.counter(:comments)
  end

  test "counter is decremented when comment recording is destroyed" do
    comment_recording = @article_recording.children.create!(recordable: Comment.new(body: "Comment to delete"))
    assert_equal 1, @article_recording.counter(:comments)

    comment_recording.destroy!
    assert_equal 0, @article_recording.counter(:comments)
  end

  test "counter is not affected by non-countable child recordings" do
    # Publication state is not countable
    @article_recording.publish!

    assert_equal 0, @article_recording.counter(:comments)
    assert_equal 0, @article_recording.counter(:publication_states)
  end

  test "counter update failure rolls back comment creation" do
    # Create a comment first to verify the transaction rollback
    initial_count = @article_recording.comments.count

    # Override increment_counter! to simulate a failure
    Recording.class_eval do
      alias_method :original_increment_counter!, :increment_counter!
      def increment_counter!(name)
        raise ActiveRecord::ActiveRecordError, "Simulated failure"
      end
    end

    assert_raises(ActiveRecord::ActiveRecordError) do
      @article_recording.children.create!(recordable: Comment.new(body: "This should fail"))
    end

    # Restore original method
    Recording.class_eval do
      alias_method :increment_counter!, :original_increment_counter!
      remove_method :original_increment_counter!
    end

    # Comment should not have been created due to rollback
    assert_equal initial_count, @article_recording.comments.count
  end
end
