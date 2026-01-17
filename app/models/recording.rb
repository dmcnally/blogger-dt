class Recording < ApplicationRecord
  include Eventable

  delegated_type :recordable, types: %w[Article], autosave: true

  belongs_to :parent, class_name: "Recording", optional: true
  has_many :children, class_name: "Recording", foreign_key: :parent_id

  validates_associated :recordable

  # Identify as the delegated type for routing purposes
  def model_name
    recordable_type&.constantize&.model_name || super
  end

  private

  # Eventable implementation
  def current_delegate = recordable
  def delegated_type_changed? = saved_change_to_recordable_type? || saved_change_to_recordable_id?
  def previous_delegate_type = recordable_type_before_last_save
  def previous_delegate_id = recordable_id_before_last_save
end
