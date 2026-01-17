module Tree
  extend ActiveSupport::Concern

  included do
    belongs_to :parent, class_name: name, optional: true
    has_many :children, class_name: name, foreign_key: :parent_id, dependent: :destroy
  end

  def root?
    parent_id.nil?
  end

  def root
    root? ? self : parent.root
  end

  def ancestors
    return [] if root?
    [parent] + parent.ancestors
  end

  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end
end
