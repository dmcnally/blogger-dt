module Article::Describable
  extend ActiveSupport::Concern

  include ::Describable

  def timeline_description(event)
    title
  end
end
