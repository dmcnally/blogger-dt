class Recording < ApplicationRecord
  include Eventable
  include Tree

  delegated_type :recordable, types: %w[Article Comment], autosave: true

  validates_associated :recordable

  # Identify as the delegated type for routing purposes
  def model_name
    recordable_type&.constantize&.model_name || super
  end

  def comments
    children.where(recordable_type: "Comment")
  end

  private

  # Eventable implementation
  def current_subject = recordable
  def subject_changed? = saved_change_to_recordable_type? || saved_change_to_recordable_id?
  def previous_subject_type = recordable_type_before_last_save
  def previous_subject_id = recordable_id_before_last_save
end
