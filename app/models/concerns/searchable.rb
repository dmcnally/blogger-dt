module Searchable
  extend ActiveSupport::Concern

  def searchable?
    false
  end

  def searchable_content
    raise NotImplementedError, "#{self.class.name} must implement #searchable_content to be searchable"
  end
end
