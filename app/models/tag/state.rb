class Tag::State < ApplicationRecord
  belongs_to :tag

  def available?
    available
  end

  def enable!
    update!(available: true)
  end

  def disable!
    update!(available: false)
  end
end
