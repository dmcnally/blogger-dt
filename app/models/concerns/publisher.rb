module Publisher
  extend ActiveSupport::Concern

  def publication_recording
    return nil unless recordable.publishable?

    children.find_by(recordable_type: "PublicationState")
  end

  def published?
    publication_recording&.recordable&.published? || false
  end

  def publish!
    return unless recordable.publishable?

    if publication_recording
      publication_recording.update!(recordable: PublicationState.published)
    else
      children.create!(recordable: PublicationState.published)
    end
  end

  def unpublish!
    return unless recordable.publishable?

    if publication_recording
      publication_recording.update!(recordable: PublicationState.not_published)
    else
      children.create!(recordable: PublicationState.not_published)
    end
  end
end
