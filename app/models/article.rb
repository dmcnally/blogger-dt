class Article < ApplicationRecord
  include Recordable

  validates :title, presence: true

  def commentable?
    true
  end

  def publishable?
    true
  end
end
