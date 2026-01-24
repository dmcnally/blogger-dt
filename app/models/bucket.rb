class Bucket < ApplicationRecord
  has_many :recordings, dependent: :restrict_with_exception
  has_many :events, dependent: :restrict_with_exception
  has_many :memberships, dependent: :destroy
  has_many :people, through: :memberships
end
