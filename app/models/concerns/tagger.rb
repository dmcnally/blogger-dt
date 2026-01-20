module Tagger
  extend ActiveSupport::Concern

  def tag_recordings
    return self.class.none unless recordable.taggable?
    children.where(recordable_type: "Tag")
  end

  def tags
    Tag.where(id: tag_recordings.select(:recordable_id))
  end

  def available_tags
    tags.available
  end

  def tag!(name)
    return unless recordable.taggable?
    tag = Tag.named(name)
    return unless tag.available?
    return if tagged?(name)
    children.create!(recordable: tag)
  end

  def untag!(name)
    return unless recordable.taggable?
    tag = Tag.find_by(name: name.to_s.strip.downcase)
    return unless tag
    tag_recordings.find_by(recordable: tag)&.destroy!
  end

  def tagged?(name)
    tag = Tag.find_by(name: name.to_s.strip.downcase)
    return false unless tag
    tag_recordings.exists?(recordable: tag)
  end
end
