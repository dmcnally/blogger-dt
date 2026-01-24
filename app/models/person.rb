class Person < ApplicationRecord
  belongs_to :recording

  has_many :memberships, dependent: :destroy
  has_many :buckets, through: :memberships

  delegate :recordable, to: :recording
  alias_method :person_card, :recordable

  def membership_for(bucket)
    memberships.find_by(bucket: bucket)
  end

  # First check: do person and resource share a bucket?
  def member_of?(bucket)
    membership_for(bucket).present?
  end

  # Role checks (implicitly require membership)
  def admin_of?(bucket)
    membership_for(bucket)&.admin?
  end

  def editor_of?(bucket)
    role = membership_for(bucket)
    role&.admin? || role&.editor?
  end

  def viewer_of?(bucket)
    member_of?(bucket) # Any member can view
  end
end
