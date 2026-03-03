class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :bucket
  attribute :user

  delegate :person, to: :user, allow_nil: true
end
