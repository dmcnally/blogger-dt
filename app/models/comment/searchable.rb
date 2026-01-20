module Comment::Searchable
  extend ActiveSupport::Concern

  include ::Searchable

  def searchable?
    true
  end

  def searchable_content
    body
  end
end
