class Article < ApplicationRecord
  include Recordable

  validates :title, presence: true

  def commentable?
    true
  end

  def publishable?
    true
  end

  def timeline_description(event)
    title
  end
end
