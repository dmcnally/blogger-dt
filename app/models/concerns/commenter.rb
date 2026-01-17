module Commenter
  extend ActiveSupport::Concern

  def comments
    return self.class.none unless recordable.commentable?

    children.where(recordable_type: "Comment")
  end
end
