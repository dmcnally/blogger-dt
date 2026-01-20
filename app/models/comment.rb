class Comment < ApplicationRecord
  include Recordable
  include Broadcastable
  include Countable
  include Describable
  include Searchable

  validates :body, presence: true
end
