module Comment::Broadcastable
  extend ActiveSupport::Concern

  include ::Broadcastable

  def broadcastable?
    true
  end

  def broadcast_on_create(recording)
    Turbo::StreamsChannel.broadcast_append_to(
      recording.parent, "comments",
      target: "comments",
      partial: "comments/comment",
      locals: { comment_recording: recording }
    )
  end

  def broadcast_on_discard(recording)
    Turbo::StreamsChannel.broadcast_remove_to(
      recording.parent, "comments",
      target: ActionView::RecordIdentifier.dom_id(recording)
    )
  end
end
