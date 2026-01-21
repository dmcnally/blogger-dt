module Broadcaster
  extend ActiveSupport::Concern

  included do
    after_create_commit :broadcast_recordable_create
    after_update_commit :broadcast_recordable_update
    after_discard :broadcast_recordable_discard
  end

  private

  def broadcast_recordable_create
    recordable.broadcast_on_create(self) if recordable.broadcastable?
  end

  def broadcast_recordable_update
    recordable.broadcast_on_update(self) if recordable.broadcastable?
  end

  def broadcast_recordable_discard
    recordable.broadcast_on_discard(self) if recordable.broadcastable?
  end
end
