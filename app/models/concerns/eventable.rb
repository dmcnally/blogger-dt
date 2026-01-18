module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy

    after_create :track_created
    after_update :track_updated, if: :subject_changed?
  end

  def creator
    events.find_by(action: "created").person
  end

  private

  def track_created
    events.create!(
      subject: current_subject,
      action: "created",
      person_id: current_person_id
    )
  end

  def track_updated
    events.create!(
      subject: current_subject,
      subject_previous_type: previous_subject_type,
      subject_previous_id: previous_subject_id,
      action: "updated",
      person_id: current_person_id
    )
  end

  def current_person_id
    return nil unless defined?(Current) && Current.respond_to?(:person)
    Current.person&.id
  end

  # Override in including class to return the current subject object
  def current_subject
    raise NotImplementedError, "Including class must define #current_subject"
  end

  # Override to check if subject columns changed
  def subject_changed?
    raise NotImplementedError, "Including class must define #subject_changed?"
  end

  # Override to return previous subject type before save
  def previous_subject_type
    raise NotImplementedError, "Including class must define #previous_subject_type"
  end

  # Override to return previous subject id before save
  def previous_subject_id
    raise NotImplementedError, "Including class must define #previous_subject_id"
  end
end
