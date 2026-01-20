module Countable
  extend ActiveSupport::Concern

  class_methods do
    def countable?
      false
    end

    def counter_name
      model_name.plural
    end

    def count_for(recording)
      raise NotImplementedError, "#{name} must implement .count_for(recording)"
    end
  end
end
