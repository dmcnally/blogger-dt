class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :person
  attribute :bucket

  delegate :user, to: :session, allow_nil: true
end
