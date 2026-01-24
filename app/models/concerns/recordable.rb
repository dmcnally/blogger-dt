module Recordable
  extend ActiveSupport::Concern

  included do
    has_one :recording, as: :recordable, touch: true

    include Broadcastable
    include Commentable
    include Countable
    include Describable
    include Immutable
    include Publishable
    include Searchable
  end
end
