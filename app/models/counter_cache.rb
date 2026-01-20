class CounterCache < ApplicationRecord
  belongs_to :counterable, polymorphic: true
end
