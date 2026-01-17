module Commentable
  extend ActiveSupport::Concern

  def commentable?
    false
  end

  def comments
    recording.children.where(recordable_type: "Comment")
  end
end
