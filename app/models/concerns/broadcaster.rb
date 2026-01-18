module Broadcaster
  extend ActiveSupport::Concern

  included do
    after_create_commit :broadcast_recordable_create
    after_update_commit :broadcast_recordable_update
    after_destroy_commit :broadcast_recordable_destroy
  end

  private

  def broadcast_recordable_create
    recordable.broadcast_on_create(self) if recordable.broadcastable?
  end

  def broadcast_recordable_update
    recordable.broadcast_on_update(self) if recordable.broadcastable?
  end

  def broadcast_recordable_destroy
    recordable.broadcast_on_destroy(self) if recordable.broadcastable?
  end
end
