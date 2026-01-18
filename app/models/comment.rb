class Comment < ApplicationRecord
  include Recordable

  validates :body, presence: true

  def timeline_description(event)
    "comment on #{event.eventable.parent&.recordable&.timeline_description(event)}"
  end
end
