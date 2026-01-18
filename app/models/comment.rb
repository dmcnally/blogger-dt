class Comment < ApplicationRecord
  include Recordable

  validates :body, presence: true

  def timeline_description(event)
    article = event.eventable.ancestor_at(Article, event)
    "comment on #{article&.timeline_description(event)}"
  end
end
