module Taggable
  extend ActiveSupport::Concern

  def taggable?
    false
  end
end
