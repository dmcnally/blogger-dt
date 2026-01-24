class Membership < ApplicationRecord
  belongs_to :person
  belongs_to :bucket

  enum :role, { viewer: 0, editor: 1, admin: 2 }
end
