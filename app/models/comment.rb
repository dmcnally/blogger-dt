class Comment < ApplicationRecord
  include Recordable
  include Broadcastable
  include Countable
  include Describable
  include Searchable

  validates :body, presence: true

  def before_discard(recording)
    recording.children.kept.find_each(&:discard!)
  end
end
