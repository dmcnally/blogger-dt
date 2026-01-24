require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @person = Current.person
    @bucket = Current.bucket
  end

  # Associations

  test "belongs to person" do
    membership = Membership.new(bucket: @bucket, role: :viewer)
    membership.person = @person

    assert_equal @person, membership.person
  end

  test "belongs to bucket" do
    membership = Membership.new(person: @person, role: :viewer)
    membership.bucket = @bucket

    assert_equal @bucket, membership.bucket
  end

  # Role enum

  test "role defaults to viewer" do
    membership = Membership.create!(person: @person, bucket: @bucket)

    assert membership.viewer?
  end

  test "role can be set to editor" do
    membership = Membership.create!(person: @person, bucket: @bucket, role: :editor)

    assert membership.editor?
  end

  test "role can be set to admin" do
    membership = Membership.create!(person: @person, bucket: @bucket, role: :admin)

    assert membership.admin?
  end

  # Uniqueness

  test "person can only have one membership per bucket" do
    Membership.create!(person: @person, bucket: @bucket)

    duplicate = Membership.new(person: @person, bucket: @bucket)

    assert_raises(ActiveRecord::RecordNotUnique) { duplicate.save! }
  end

  test "person can have memberships in multiple buckets" do
    other_bucket = Bucket.create!(name: "Other Bucket")

    membership1 = Membership.create!(person: @person, bucket: @bucket)
    membership2 = Membership.create!(person: @person, bucket: other_bucket)

    assert_equal 2, @person.memberships.count
  end
end
