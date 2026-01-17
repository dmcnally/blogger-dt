module Commentable
  extend ActiveSupport::Concern

  def commentable?
    false
  end
end
