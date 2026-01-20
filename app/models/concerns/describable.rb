module Describable
  extend ActiveSupport::Concern

  def timeline_description(event)
    self.class.model_name.human.downcase
  end
end
