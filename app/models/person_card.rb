class PersonCard < ApplicationRecord
  include Recordable

  def name
    [first_name, last_name].compact.join(" ")
  end

  def timeline_description(event)
    name
  end
end
