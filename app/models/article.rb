class Article < ApplicationRecord
  include Recordable
  include Describable
  include Searchable

  validates :title, presence: true

  def commentable?
    true
  end

  def publishable?
    true
  end

  def before_discard(recording)
    recording.children.kept.find_each(&:discard!)
  end
end
