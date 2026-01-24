class Comment < ApplicationRecord
  include Recordable

  validates :body, presence: true

  def before_discard(recording)
    recording.children.kept.find_each(&:discard!)
  end

  # Permission methods
  def editable_by?(person)
    person.editor_of?(recording.bucket)
  end

  def deletable_by?(person)
    person.admin_of?(recording.bucket) || recording.creator == person
  end

  def viewable_by?(person)
    person.viewer_of?(recording.bucket)
  end
end
