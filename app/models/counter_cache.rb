class CounterCache < ApplicationRecord
  belongs_to :counterable, polymorphic: true

  def self.for(counterable, name)
    find_or_create_by!(counterable: counterable, name: name.to_s)
  end

  def broadcast_update
    Turbo::StreamsChannel.broadcast_replace_to(
      counterable,
      target: self,
      partial: "counter_caches/counter_cache",
      locals: { counter_cache: self }
    )
  end
end
