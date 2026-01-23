class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def self.with_name(name)
    find_or_create_by!(name: name)
  end
end
