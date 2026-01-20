class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :subject, polymorphic: true
  belongs_to :subject_previous, polymorphic: true, optional: true
  belongs_to :person

  has_many :details, class_name: "Event::Detail", dependent: :destroy

  validates :action, presence: true

  after_create_commit :broadcast_timeline_append

  private

  def broadcast_timeline_append
    root_recording = eventable.root
    Turbo::StreamsChannel.broadcast_append_to(
      root_recording, "timeline",
      target: ActionView::RecordIdentifier.dom_id(root_recording, :timeline_events),
      partial: "timelines/event",
      locals: { event: self }
    )
  end
end
