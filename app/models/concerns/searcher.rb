module Searcher
  extend ActiveSupport::Concern

  included do
    has_one :search_index, dependent: :destroy
    after_save :update_search_index, if: :should_update_search_index?
  end

  class_methods do
    def search(query, recordable_type: nil)
      scope = joins(:search_index)
              .where("search_indices.searchable @@ plainto_tsquery('english', ?)", query)
      scope = scope.where(search_indices: { recordable_type: recordable_type }) if recordable_type.present?
      scope
    end
  end

  private

  def should_update_search_index?
    recordable&.searchable? && (saved_change_to_recordable_id? || saved_change_to_recordable_type?)
  end

  def update_search_index
    search_index&.destroy
    create_search_index!(
      recordable_type: recordable_type,
      content: recordable.searchable_content
    )
  end
end
