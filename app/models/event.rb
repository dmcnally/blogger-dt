class Event < ApplicationRecord
  include Bucketable

  belongs_to :eventable, polymorphic: true, touch: true
  belongs_to :subject, polymorphic: true
  belongs_to :subject_previous, polymorphic: true, optional: true
  belongs_to :person, optional: true

  has_many :details, class_name: "Event::Detail", dependent: :destroy

  validates :action, presence: true

  after_create_commit :broadcast_timeline_append

  def partial_path
    specialized = "timelines/events/#{action}_#{subject_type.underscore}"

    if Rails.root.join("app/views/timelines/events/_#{action}_#{subject_type.underscore}.html.erb").exist?
      specialized
    else
      "timelines/event"
    end
  end

  private

  def broadcast_timeline_append
    root_recording = eventable.root
    Turbo::StreamsChannel.broadcast_append_to(
      root_recording, "timeline",
      target: ActionView::RecordIdentifier.dom_id(root_recording, :timeline_events),
      partial: partial_path,
      locals: { event: self }
    )
  end
end
