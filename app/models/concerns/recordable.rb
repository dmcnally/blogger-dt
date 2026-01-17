module Recordable
  extend ActiveSupport::Concern

  included do
    include Commentable

    has_one :recording, as: :recordable, touch: true

    # Enforce immutability
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
  end
end
