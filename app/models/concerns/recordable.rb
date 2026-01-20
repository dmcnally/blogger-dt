module Recordable
  extend ActiveSupport::Concern

  included do
    include Broadcastable
    include Commentable
    include Countable
    include Describable
    include Immutable
    include Publishable
    include Searchable
    include Taggable
  end
end
