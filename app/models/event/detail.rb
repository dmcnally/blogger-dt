class Event::Detail < ApplicationRecord
  include Immutable

  self.table_name = "event_details"

  belongs_to :event

  validates :key, presence: true, uniqueness: { scope: :event_id }
end
