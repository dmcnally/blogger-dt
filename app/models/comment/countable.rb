module Comment::Countable
  extend ActiveSupport::Concern
  include ::Countable

  class_methods do
    def countable?
      true
    end

    def count_for(recording)
      recording.comments.count
    end
  end
end
