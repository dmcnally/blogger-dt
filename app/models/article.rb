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

  def taggable?
    true
  end
end
