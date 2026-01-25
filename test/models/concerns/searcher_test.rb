require "test_helper"

class SearcherTest < ActiveSupport::TestCase
  setup do
    @article = Article.new(title: "Ruby on Rails", body: "A web framework for building applications")
    @article_recording = Recording.create!(recordable: @article)
  end

  # search_index creation

  test "creates search_index on save for searchable recordable" do
    assert @article_recording.search_index.present?
    assert_equal "Article", @article_recording.search_index.recordable_type
  end

  test "search_index contains searchable content from recordable" do
    content = @article_recording.search_index.content

    assert_includes content, "Ruby on Rails"
    assert_includes content, "web framework"
  end

  # search_index updates

  test "updates search_index when recordable changes" do
    new_article = Article.new(title: "Python Django", body: "Another web framework")
    @article_recording.update!(recordable: new_article)

    assert_includes @article_recording.search_index.content, "Python Django"
    refute_includes @article_recording.search_index.content, "Ruby on Rails"
  end

  test "keeps same search_index record when recordable changes" do
    old_search_index_id = @article_recording.search_index.id

    new_article = Article.new(title: "New Article", body: "New content")
    @article_recording.update!(recordable: new_article)

    assert_equal old_search_index_id, @article_recording.search_index.id
  end

  # Recording.search

  test "Recording.search finds recordings matching query" do
    results = Recording.search("Ruby")

    assert_includes results, @article_recording
  end

  test "Recording.search does not find non-matching recordings" do
    results = Recording.search("Python")

    refute_includes results, @article_recording
  end

  test "Recording.search returns empty when no matches" do
    results = Recording.search("nonexistent term xyz")

    assert_empty results
  end

  test "Recording.search filters by recordable_type when specified" do
    comment = Comment.new(body: "Ruby is great for web development")
    comment_recording = @article_recording.children.create!(recordable: comment)

    article_results = Recording.search("Ruby", recordable_type: "Article")
    comment_results = Recording.search("Ruby", recordable_type: "Comment")

    assert_includes article_results, @article_recording
    refute_includes article_results, comment_recording

    assert_includes comment_results, comment_recording
    refute_includes comment_results, @article_recording
  end

  test "Recording.search finds multiple matching recordings" do
    article2 = Article.new(title: "More Ruby", body: "Ruby content")
    recording2 = Recording.create!(recordable: article2)

    results = Recording.search("Ruby")

    assert_includes results, @article_recording
    assert_includes results, recording2
  end

  # has_one association

  test "search_index is destroyed when recording is discarded" do
    search_index_id = @article_recording.search_index.id

    @article_recording.discard!

    refute SearchIndex.exists?(search_index_id)
  end
end
