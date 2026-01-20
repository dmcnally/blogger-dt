class Person < ApplicationRecord
  belongs_to :recording

  delegate :recordable, to: :recording
  alias_method :person_card, :recordable
end
