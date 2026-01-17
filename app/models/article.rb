class Article < ApplicationRecord
  include Recordable

  validates :title, presence: true

  def commentable?
    true
  end
end
