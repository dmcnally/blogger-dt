class Article < ApplicationRecord
  include Recordable

  validates :title, presence: true

  def commentable?
    true
  end

  def publishable?
    true
  end

  def searchable?
    true
  end

  def searchable_content
    [title, body].compact.join(" ")
  end

  def timeline_description(event)
    title
  end
end
