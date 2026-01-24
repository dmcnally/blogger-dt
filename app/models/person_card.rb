class PersonCard < ApplicationRecord
  include Recordable

  def name
    [ first_name, last_name ].compact.join(" ")
  end

  def searchable?
    true
  end

  def searchable_content
    name
  end

  def timeline_description(event)
    name
  end

  # Permission methods - owner OR admin can edit
  def editable_by?(person)
    owner?(person) || person.admin_of?(recording.bucket)
  end

  def deletable_by?(person)
    person.admin_of?(recording.bucket)
  end

  def viewable_by?(person)
    person.viewer_of?(recording.bucket)
  end

  private

  def owner?(person)
    person.person_card == self
  end
end
