class PublicationState < ApplicationRecord
  include Recordable

  PUBLISHED = "published"
  NOT_PUBLISHED = "notPublished"

  validates :state, presence: true, inclusion: { in: [PUBLISHED, NOT_PUBLISHED] }, uniqueness: true

  def published?
    state == PUBLISHED
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
