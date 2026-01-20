class SearchIndex < ApplicationRecord
  belongs_to :recording

  class << self
    def search(query, recordable_type: nil)
      scope = where("searchable @@ plainto_tsquery('english', ?)", query)
      scope = scope.where(recordable_type: recordable_type) if recordable_type.present?
      scope
    end
  end
end
