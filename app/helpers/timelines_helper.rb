module TimelinesHelper
  def event_partial_path(event)
    specialized = "timelines/events/#{event.action}_#{event.subject_type.underscore}"

    if lookup_context.exists?(specialized, [], true)
      specialized
    else
      "timelines/event"
    end
  end
end
