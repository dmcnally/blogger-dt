module Recordable
  extend ActiveSupport::Concern

  included do
    include Commentable
    include Publishable

    # Enforce immutability
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
  end
end
