module Publisher
  extend ActiveSupport::Concern


  included do
    has_one :publication, dependent: :destroy

    scope :published, -> { joins(:publication) }
    scope :unpublished, -> { left_joins(:publication).where.missing(:publication) }
  end

  def published?
    publication.present?
  end

  def publish!
    return unless recordable.publishable?
    return if published?

    create_publication!
    track_publication_event("published")
  end

  def unpublish!
    return unless recordable.publishable?
    return unless published?

    publication.destroy!
    reload_publication
    track_publication_event("unpublished")
  end

  private

  def track_publication_event(action)
    events.create!(
      subject: recordable,
      action: action,
      person_id: Current.person&.id
    )
  end
end
