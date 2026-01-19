class Comment < ApplicationRecord
  include Recordable
  include Broadcastable
  include Describable
  include Searchable

  validates :body, presence: true
end
