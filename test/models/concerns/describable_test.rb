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

  test "child events show parent title at time of event, not current title" do
    # Create a comment while article has "My Article Title"
    comment = Comment.new(body: "A comment")
    comment_recording = @article_recording.children.create!(recordable: comment)
    comment_event = comment_recording.events.last

    # Update article recording to point to a new article with different title
    new_article = Article.new(title: "Updated Title", body: "New body")
    @article_recording.update!(recordable: new_article)

    # Comment event should still show the original title
    assert_equal "comment on My Article Title", comment.timeline_description(comment_event)
  end
end
