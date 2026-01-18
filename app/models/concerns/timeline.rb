module Timeline
  extend ActiveSupport::Concern

  def timeline_events
    Event.where(eventable: [self] + descendants)
         .includes(:person)
         .order(created_at: :asc)
  end
end
