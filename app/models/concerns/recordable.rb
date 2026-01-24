module Recordable
  extend ActiveSupport::Concern

  CONCERNS = %i[Broadcastable Commentable Countable Describable Immutable Publishable Searchable].freeze

  included do
    has_one :recording, as: :recordable, touch: true

    CONCERNS.each do |concern_name|
      # Check for specialized version (e.g., Article::Searchable) first
      specialized = "#{name}::#{concern_name}".safe_constantize
      include specialized || concern_name.to_s.constantize
    end
  end
end
