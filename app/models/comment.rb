class Comment < ApplicationRecord
  include Recordable

  validates :body, presence: true
end
