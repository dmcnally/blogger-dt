module Recordable
  extend ActiveSupport::Concern

  included do
    include Broadcastable
    include Commentable
    include Describable
    include Immutable
    include Publishable
    include Searchable
  end
end
