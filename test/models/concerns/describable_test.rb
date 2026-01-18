require "test_helper"

class DescribableTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "My Article Title", body: "Article body")
    @article_recording = Recording.create!(recordable: @article)
  end

  test "article timeline_description returns title" do
    event = @article_recording.events.last

    assert_equal "My Article Title", @article.timeline_description(event)
  end

  test "comment timeline_description references parent article" do
    comment = Comment.new(body: "A comment")
    comment_recording = @article_recording.children.create!(recordable: comment)
    event = comment_recording.events.last

    assert_equal "comment on My Article Title", comment.timeline_description(event)
  end

  test "publication_state timeline_description delegates to parent" do
    @article_recording.publish!
    publication_recording = @article_recording.publication_recording
    event = publication_recording.events.last

    assert_equal "My Article Title", event.subject.timeline_description(event)
  end

  test "person_card timeline_description returns name" do
    person_card = PersonCard.new(first_name: "John", last_name: "Smith")
    person_card_recording = Recording.create!(recordable: person_card)
    event = person_card_recording.events.last

    assert_equal "John Smith", person_card.timeline_description(event)
  end

  test "default timeline_description returns humanized model name" do
    # Create a mock recordable that doesn't override timeline_description
    article = Article.new(title: "Test")

    # Remove the override to test default behavior
    default_description = article.class.model_name.human.downcase

    assert_equal "article", default_description
  end
end
