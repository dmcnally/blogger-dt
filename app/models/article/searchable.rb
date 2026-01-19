module Article::Searchable
  extend ActiveSupport::Concern

  include ::Searchable

  def searchable?
    true
  end

  def searchable_content
    [title, body].compact.join(" ")
  end
end
