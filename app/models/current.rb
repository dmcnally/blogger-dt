class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :bucket

  delegate :user, to: :session, allow_nil: true
  delegate :person, to: :user, allow_nil: true
end
