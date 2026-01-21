require "test_helper"

class BroadcasterTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @article_recording = Recording.create!(recordable: @article)
    Thread.current[:broadcast_calls] = []
  end

  teardown do
    Thread.current[:broadcast_calls] = nil
  end

  # broadcast_on_create

  test "calls broadcast_on_create after recording create for broadcastable recordable" do
    comment = Comment.new(body: "Test comment")

    comment.define_singleton_method(:broadcastable?) { true }
    comment.define_singleton_method(:broadcast_on_create) do |recording|
      Thread.current[:broadcast_calls] << [ :create, recording ]
    end

    comment_recording = @article_recording.children.create!(recordable: comment)

    assert_includes Thread.current[:broadcast_calls].map(&:first), :create
  end

  test "does not call broadcast_on_create for non-broadcastable recordable" do
    comment = Comment.new(body: "Test comment")

    # Explicitly ensure broadcastable? returns false
    comment.define_singleton_method(:broadcastable?) { false }
    comment.define_singleton_method(:broadcast_on_create) do |recording|
      Thread.current[:broadcast_calls] << [ :create, recording ]
    end

    @article_recording.children.create!(recordable: comment)

    refute_includes Thread.current[:broadcast_calls].map(&:first), :create
  end

  # broadcast_on_update

  test "calls broadcast_on_update after recording update for broadcastable recordable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    comment.define_singleton_method(:broadcastable?) { true }
    comment.define_singleton_method(:broadcast_on_update) do |recording|
      Thread.current[:broadcast_calls] << [ :update, recording ]
    end

    comment_recording.touch

    assert_includes Thread.current[:broadcast_calls].map(&:first), :update
  end

  test "does not call broadcast_on_update for non-broadcastable recordable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    comment.define_singleton_method(:broadcastable?) { false }
    comment.define_singleton_method(:broadcast_on_update) do |recording|
      Thread.current[:broadcast_calls] << [ :update, recording ]
    end

    comment_recording.touch

    refute_includes Thread.current[:broadcast_calls].map(&:first), :update
  end

  # broadcast_on_discard

  test "calls broadcast_on_discard after recording discard for broadcastable recordable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    comment.define_singleton_method(:broadcastable?) { true }
    comment.define_singleton_method(:broadcast_on_discard) do |recording|
      Thread.current[:broadcast_calls] << [ :discard, recording ]
    end

    comment_recording.discard!

    assert_includes Thread.current[:broadcast_calls].map(&:first), :discard
  end

  test "does not call broadcast_on_discard for non-broadcastable recordable" do
    comment = Comment.new(body: "Test comment")
    comment_recording = @article_recording.children.create!(recordable: comment)

    comment.define_singleton_method(:broadcastable?) { false }
    comment.define_singleton_method(:broadcast_on_discard) do |recording|
      Thread.current[:broadcast_calls] << [ :discard, recording ]
    end

    comment_recording.discard!

    refute_includes Thread.current[:broadcast_calls].map(&:first), :discard
  end

  # Broadcast method receives recording

  test "broadcast_on_create receives the recording as argument" do
    comment = Comment.new(body: "Test comment")

    comment.define_singleton_method(:broadcastable?) { true }
    comment.define_singleton_method(:broadcast_on_create) do |recording|
      Thread.current[:broadcast_calls] << [ :create, recording ]
    end

    comment_recording = @article_recording.children.create!(recordable: comment)

    create_call = Thread.current[:broadcast_calls].find { |action, _| action == :create }
    assert_equal comment_recording, create_call[1]
  end
end
