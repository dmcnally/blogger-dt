class Article < ApplicationRecord
  include Recordable

  validates :title, presence: true
end
