module Publishable
  extend ActiveSupport::Concern

  def publishable?
    false
  end
end
