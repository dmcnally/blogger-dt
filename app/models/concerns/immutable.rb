module Immutable
  extend ActiveSupport::Concern

  included do
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
  end
end
