module Broadcastable
  extend ActiveSupport::Concern

  def broadcastable?
    false
  end

  def broadcast_on_create(recording)
    # Override in recordable to broadcast on create
  end

  def broadcast_on_update(recording)
    # Override in recordable to broadcast on update
  end

  def broadcast_on_discard(recording)
    # Override in recordable to broadcast on discard
  end
end
