class Comment < ApplicationRecord
  include Recordable

  validates :body, presence: true

  def broadcastable?
    true
  end

  def searchable?
    true
  end

  def searchable_content
    body
  end

  def timeline_description(event)
    article = event.eventable.ancestor_at(Article, event)
    "comment on #{article&.timeline_description(event)}"
  end

  def broadcast_on_create(recording)
    Turbo::StreamsChannel.broadcast_append_to(
      recording.parent, "comments",
      target: "comments",
      partial: "comments/comment",
      locals: { comment_recording: recording }
    )
  end

  def broadcast_on_destroy(recording)
    Turbo::StreamsChannel.broadcast_remove_to(
      recording.parent, "comments",
      target: ActionView::RecordIdentifier.dom_id(recording)
    )
  end
end
