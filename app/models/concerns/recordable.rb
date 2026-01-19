module Recordable
  extend ActiveSupport::Concern

  included do
    include Broadcastable
    include Commentable
    include Describable
    include Publishable
    include Searchable

    # Enforce immutability
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
  end
end
