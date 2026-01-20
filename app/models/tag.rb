class Tag < ApplicationRecord
  include Recordable

  has_one :state, class_name: "Tag::State", dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def available?
    state&.available? || false
  end

  class << self
    def named(name)
      normalized = name.to_s.strip.downcase
      tag = find_or_create_by!(name: normalized)
      tag.state || tag.create_state!(available: true)
      tag
    end

    def available
      joins(:state).where(tag_states: { available: true })
    end
  end
end
