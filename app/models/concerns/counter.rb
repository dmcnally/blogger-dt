module Counter
  extend ActiveSupport::Concern

  included do
    has_many :counter_caches, as: :counterable, dependent: :destroy, class_name: "CounterCache"
    after_create :increment_parent_counter
    after_destroy :decrement_parent_counter
  end

  def counter(name)
    counter_caches.find_by(name: name.to_s)&.count || 0
  end

  def increment_counter!(name)
    cache = counter_caches.find_or_create_by!(name: name.to_s)
    CounterCache.increment_counter(:count, cache.id)
  end

  def decrement_counter!(name)
    cache = counter_caches.find_by(name: name.to_s)
    CounterCache.decrement_counter(:count, cache.id) if cache&.count&.positive?
  end

  def refresh_counter!(name)
    klass = name.to_s.classify.constantize
    return unless klass.countable?
    value = klass.count_for(self)
    cache = counter_caches.find_or_initialize_by(name: name.to_s)
    cache.update!(count: value)
  end

  def refresh_all_counters!
    Recording::RECORDABLE_TYPES.each do |type_name|
      klass = type_name.constantize
      refresh_counter!(klass.counter_name) if klass.countable?
    end
  end

  private

  def increment_parent_counter
    return unless parent && recordable.class.countable?
    parent.increment_counter!(recordable.class.counter_name)
  end

  def decrement_parent_counter
    return unless parent && recordable.class.countable?
    parent.decrement_counter!(recordable.class.counter_name)
  end
end
