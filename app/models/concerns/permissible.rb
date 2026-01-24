module Permissible
  extend ActiveSupport::Concern

  def editable_by?(person)
    recordable.editable_by?(person)
  end

  def deletable_by?(person)
    recordable.deletable_by?(person)
  end

  def viewable_by?(person)
    recordable.viewable_by?(person)
  end
end
