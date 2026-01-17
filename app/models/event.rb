class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :subject, polymorphic: true
  belongs_to :subject_previous, polymorphic: true, optional: true
  # TODO: Uncomment when Person model is created
  # belongs_to :person, optional: true

  has_many :details, class_name: "Event::Detail", dependent: :destroy

  validates :action, presence: true
end
