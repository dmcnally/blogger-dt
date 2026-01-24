class Recording < ApplicationRecord
  include Bucketable
  include Discardable
  include Counter
  include Eventable
  include Tree
  include Timeline
  include Commenter
  include Publisher
  include Broadcaster
  include Searcher
  include Permissible

  RECORDABLE_TYPES = %w[Article Comment PersonCard].freeze

  delegated_type :recordable, types: RECORDABLE_TYPES, autosave: true

  validates_associated :recordable
  validate :bucket_matches_parent, if: :parent

  # Identify as the delegated type for routing purposes
  def model_name
    recordable_type&.constantize&.model_name || super
  end

  private

  def bucket_matches_parent
    if bucket != parent.bucket
      errors.add(:bucket, "must match parent's bucket")
    end
  end

  # Eventable implementation
  def current_subject = recordable
  def subject_changed? = saved_change_to_recordable_type? || saved_change_to_recordable_id?
  def previous_subject_type = recordable_type_before_last_save
  def previous_subject_id = recordable_id_before_last_save
end
