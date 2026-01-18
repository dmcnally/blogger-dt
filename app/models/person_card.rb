class PersonCard < ApplicationRecord
  include Recordable

  def name
    [first_name, last_name].compact.join(" ")
  end
end
