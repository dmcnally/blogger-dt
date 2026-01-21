module Timeline
  extend ActiveSupport::Concern

  def timeline_events
    Event.where(eventable: [ self ] + descendants)
         .includes(:person)
         .order(created_at: :asc)
  end

  def ancestor_recording(type)
    ancestors.find { |a| a.recordable_type == type.name }
  end

  def subject_at(event)
    events.where("created_at <= ?", event.created_at)
          .order(created_at: :desc)
          .first&.subject
  end

  def ancestor_at(type, event)
    ancestor_recording(type)&.subject_at(event)
  end
end
