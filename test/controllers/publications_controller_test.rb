require "test_helper"

class PublicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = Article.new(title: "Test Article", body: "Test body")
    @recording = Recording.create!(recordable: @article)
    sign_in_as users(:one)
  end

  test "create publishes the recording" do
    refute @recording.published?

    post recording_publication_path(@recording)

    @recording.reload
    assert @recording.published?
    assert_redirected_to @recording
  end

  test "create responds with turbo_stream" do
    post recording_publication_path(@recording), as: :turbo_stream

    assert_response :success
    assert_match "turbo-stream", response.body
  end

  test "destroy unpublishes the recording" do
    @recording.publish!
    assert @recording.published?

    delete recording_publication_path(@recording)

    @recording.reload
    refute @recording.published?
    assert_redirected_to @recording
  end

  test "destroy responds with turbo_stream" do
    @recording.publish!

    delete recording_publication_path(@recording), as: :turbo_stream

    assert_response :success
    assert_match "turbo-stream", response.body
  end
end
