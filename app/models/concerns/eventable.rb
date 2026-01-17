module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy

    after_create :track_created
    after_update :track_updated, if: :delegated_type_changed?
  end

  private

  def track_created
    events.create!(
      recordable: current_delegate,
      action: "created",
      person_id: current_person_id
    )
  end

  def track_updated
    events.create!(
      recordable: current_delegate,
      recordable_previous_type: previous_delegate_type,
      recordable_previous_id: previous_delegate_id,
      action: "updated",
      person_id: current_person_id
    )
  end

  def current_person_id
    return nil unless defined?(Current) && Current.respond_to?(:person)
    Current.person&.id
  end

  # Override in including class to return the current delegate object
  def current_delegate
    raise NotImplementedError, "Including class must define #current_delegate"
  end

  # Override to check if delegated type columns changed
  def delegated_type_changed?
    raise NotImplementedError, "Including class must define #delegated_type_changed?"
  end

  # Override to return previous delegate type before save
  def previous_delegate_type
    raise NotImplementedError, "Including class must define #previous_delegate_type"
  end

  # Override to return previous delegate id before save
  def previous_delegate_id
    raise NotImplementedError, "Including class must define #previous_delegate_id"
  end
end
