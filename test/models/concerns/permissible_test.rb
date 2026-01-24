require "test_helper"

class PermissibleTest < ActiveSupport::TestCase
  setup do
    @bucket = Current.bucket
    @person = Current.person
  end

  # Person role helper methods

  test "member_of? returns true when person has membership in bucket" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)

    assert @person.member_of?(@bucket)
  end

  test "member_of? returns false when person has no membership in bucket" do
    other_bucket = Bucket.create!(name: "Other Bucket")

    refute @person.member_of?(other_bucket)
  end

  test "viewer_of? returns true for any membership" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)

    assert @person.viewer_of?(@bucket)
  end

  test "editor_of? returns true for editor role" do
    Membership.create!(person: @person, bucket: @bucket, role: :editor)

    assert @person.editor_of?(@bucket)
  end

  test "editor_of? returns true for admin role" do
    Membership.create!(person: @person, bucket: @bucket, role: :admin)

    assert @person.editor_of?(@bucket)
  end

  test "editor_of? returns false for viewer role" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)

    refute @person.editor_of?(@bucket)
  end

  test "admin_of? returns true for admin role" do
    Membership.create!(person: @person, bucket: @bucket, role: :admin)

    assert @person.admin_of?(@bucket)
  end

  test "admin_of? returns false for editor role" do
    Membership.create!(person: @person, bucket: @bucket, role: :editor)

    refute @person.admin_of?(@bucket)
  end

  # Recording delegates to recordable

  test "recording.editable_by? delegates to recordable" do
    Membership.create!(person: @person, bucket: @bucket, role: :editor)
    article = Article.new(title: "Test Article")
    recording = Recording.create!(recordable: article)

    assert recording.editable_by?(@person)
  end

  test "recording.viewable_by? delegates to recordable" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)
    article = Article.new(title: "Test Article")
    recording = Recording.create!(recordable: article)

    assert recording.viewable_by?(@person)
  end

  # Article permission defaults

  test "article is editable by editor" do
    Membership.create!(person: @person, bucket: @bucket, role: :editor)
    article = Article.new(title: "Test Article")
    Recording.create!(recordable: article)

    assert article.editable_by?(@person)
  end

  test "article is not editable by viewer" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)
    article = Article.new(title: "Test Article")
    Recording.create!(recordable: article)

    refute article.editable_by?(@person)
  end

  test "article is deletable by admin" do
    Membership.create!(person: @person, bucket: @bucket, role: :admin)
    article = Article.new(title: "Test Article")
    Recording.create!(recordable: article)

    assert article.deletable_by?(@person)
  end

  test "article is deletable by creator" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)
    article = Article.new(title: "Test Article")
    recording = Recording.create!(recordable: article)

    assert article.deletable_by?(@person)
  end

  test "article is not deletable by non-creator viewer" do
    # Create a different person who is not the creator
    other_person_card = PersonCard.create!(first_name: "Other", last_name: "User")
    other_recording = Recording.create!(recordable: other_person_card)
    other_person = Person.create!(recording: other_recording)
    Membership.create!(person: other_person, bucket: @bucket, role: :viewer)

    article = Article.new(title: "Test Article")
    Recording.create!(recordable: article)

    refute article.deletable_by?(other_person)
  end

  # PersonCard permission overrides

  test "person_card is editable by owner" do
    Membership.create!(person: @person, bucket: @bucket, role: :viewer)

    assert @person.person_card.editable_by?(@person)
  end

  test "person_card is editable by admin even if not owner" do
    # Create another person who is admin
    other_person_card = PersonCard.create!(first_name: "Admin", last_name: "User")
    other_recording = Recording.create!(recordable: other_person_card)
    other_person = Person.create!(recording: other_recording)
    Membership.create!(person: other_person, bucket: @bucket, role: :admin)

    assert @person.person_card.editable_by?(other_person)
  end

  test "person_card is not editable by non-owner editor" do
    # Create another person who is editor but not owner
    other_person_card = PersonCard.create!(first_name: "Editor", last_name: "User")
    other_recording = Recording.create!(recordable: other_person_card)
    other_person = Person.create!(recording: other_recording)
    Membership.create!(person: other_person, bucket: @bucket, role: :editor)

    refute @person.person_card.editable_by?(other_person)
  end

  test "person_card is only deletable by admin" do
    Membership.create!(person: @person, bucket: @bucket, role: :admin)

    assert @person.person_card.deletable_by?(@person)
  end

  test "person_card is not deletable by owner if not admin" do
    Membership.create!(person: @person, bucket: @bucket, role: :editor)

    refute @person.person_card.deletable_by?(@person)
  end
end
