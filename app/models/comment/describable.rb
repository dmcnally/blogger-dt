module Comment::Describable
  extend ActiveSupport::Concern

  include ::Describable

  def timeline_description(event)
    article = event.eventable.ancestor_at(Article, event)
    "comment on #{article&.timeline_description(event)}"
  end
end
