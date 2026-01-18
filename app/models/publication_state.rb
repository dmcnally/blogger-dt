class PublicationState < ApplicationRecord
  include Recordable

  PUBLISHED = "published"
  NOT_PUBLISHED = "notPublished"

  validates :state, presence: true, inclusion: { in: [PUBLISHED, NOT_PUBLISHED] }, uniqueness: true

  def published?
    state == PUBLISHED
  end

  def event_action
    published? ? "published" : "unpublished"
  end

  def timeline_description(event)
    event.eventable.parent&.recordable&.timeline_description(event)
  end

  class << self
    def published
      find_or_create_by!(state: PUBLISHED)
    end

    def not_published
      find_or_create_by!(state: NOT_PUBLISHED)
    end
  end
end
