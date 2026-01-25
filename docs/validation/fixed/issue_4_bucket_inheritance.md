# Validation Report: Issue 4 - Child Recordings Don't Inherit Bucket

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED

---

## Issue Hypothesis

The `Bucketable` concern sets the bucket from `Current.bucket` only, ignoring the parent recording's bucket. This could cause child recordings to end up in a different bucket than their parent if `Current.bucket` differs from the parent's bucket.

---

## Independent Code Analysis

### Evidence Location 1: Bucketable Concern Implementation

**File:** `app/models/concerns/bucketable.rb`  
**Lines:** 1-19

```ruby
module Bucketable
  extend ActiveSupport::Concern

  included do
    belongs_to :bucket

    before_validation :set_bucket_from_current, on: :create
  end

  private

  def set_bucket_from_current
    return if bucket.present?

    raise "Current.bucket must be set" unless Current.bucket

    self.bucket = Current.bucket
  end
end
```

**Key Observations:**
- Line 7: Callback runs `on: :create`
- Line 12: Returns early if bucket already set
- Line 14: Raises if `Current.bucket` is nil
- Line 16: Sets bucket from `Current.bucket` only
- **No reference to `parent` or parent's bucket**

### Evidence Location 2: Recording Uses Tree Concern

**File:** `app/models/recording.rb`  
**Lines:** 1-7

```ruby
class Recording < ApplicationRecord
  include Bucketable
  include Discardable
  include Counter
  include Eventable
  include Tree
  # ...
```

**File:** `app/models/concerns/tree.rb`  
**Lines:** 1-7

```ruby
module Tree
  extend ActiveSupport::Concern

  included do
    belongs_to :parent, class_name: name, optional: true, touch: true
    has_many :children, class_name: name, foreign_key: :parent_id, dependent: :restrict_with_exception
  end
```

**Observation:** `Recording` has `parent` association via `Tree`, but `Bucketable` doesn't use it.

### Evidence Location 3: CommentsController Creates Child Recordings

**File:** `app/controllers/comments_controller.rb`  
**Lines:** 5-10

```ruby
def create
  @comment_recording = @parent_recording.children.build(
    recordable: Comment.new(comment_params)
  )

  if @comment_recording.save
```

**Observation:** Child recording is built via `@parent_recording.children.build`, which sets `parent_id` but not `bucket_id`.

### Evidence Location 4: ApplicationController Sets Current.bucket

**File:** `app/controllers/application_controller.rb`  
**Lines:** 13-17

```ruby
def set_current_person
  # TODO: Replace with current_user.person when authentication is added
  Current.person = Person.first
  Current.bucket = Bucket.first
end
```

**Observation:** Currently hardcoded to `Bucket.first`, which may differ from parent's bucket.

---

## Scenario Analysis

### Normal Case (Currently Working)

1. User views article in Bucket A
2. `Current.bucket` is set to Bucket A
3. User creates comment
4. Comment recording gets `bucket_id` from `Current.bucket` (Bucket A)
5. **Result:** Parent and child have same bucket

### Failure Case (Potential Bug)

1. Article exists in Bucket A
2. Due to bug/race condition, `Current.bucket` is Bucket B
3. User creates comment on the article
4. Comment recording gets `bucket_id` from `Current.bucket` (Bucket B)
5. **Result:** Parent in Bucket A, child in Bucket B - **Data inconsistency!**

### Why This Matters

- **Tree integrity:** A tree should be contained within one bucket
- **Permission model:** Bucket membership determines access; mixed buckets break this
- **Query assumptions:** Code may assume `parent.bucket == child.bucket`

---

## Reproduction Steps

### Manual Test Case

```ruby
# Rails console:
bucket_a = Bucket.create!(name: "Bucket A")
bucket_b = Bucket.create!(name: "Bucket B")

# Create article in Bucket A
Current.bucket = bucket_a
Current.person = Person.first
article = Article.create!(title: "Test Article", body: "Body")
article_recording = Recording.create!(recordable: article)

# Simulate bug: Current.bucket differs from parent
Current.bucket = bucket_b

# Create comment as child
comment = Comment.create!(body: "Test comment")
comment_recording = article_recording.children.build(recordable: comment)
comment_recording.save!

# Check buckets
puts "Article bucket: #{article_recording.bucket.name}"   # => Bucket A
puts "Comment bucket: #{comment_recording.bucket.name}"   # => Bucket B (WRONG!)
puts "Same bucket? #{article_recording.bucket == comment_recording.bucket}"  # => false
```

### Automated Test Case

```ruby
# test/models/concerns/bucketable_test.rb
require "test_helper"

class BucketableTest < ActiveSupport::TestCase
  test "child recording inherits parent bucket" do
    bucket_a = Bucket.create!(name: "Bucket A")
    bucket_b = Bucket.create!(name: "Bucket B")
    
    Current.bucket = bucket_a
    parent_recording = Recording.create!(recordable: Article.new(title: "Parent"))
    
    # Change Current.bucket to simulate misconfig
    Current.bucket = bucket_b
    
    child_recording = parent_recording.children.build(
      recordable: Comment.new(body: "Child")
    )
    child_recording.save!
    
    # This assertion currently FAILS
    assert_equal parent_recording.bucket, child_recording.bucket,
      "Child should inherit parent's bucket, not Current.bucket"
  end
end
```

---

## Confirmation

**Issue Status: CONFIRMED**

The `Bucketable` concern does not inherit bucket from parent. The callback:

```ruby
def set_bucket_from_current
  return if bucket.present?
  raise "Current.bucket must be set" unless Current.bucket
  self.bucket = Current.bucket
end
```

Has no awareness of parent recordings.

---

## Severity Assessment

**Severity: High (Data Integrity)**

- **Data Integrity Impact:** High - tree can span multiple buckets
- **Security Impact:** Medium - permission model assumes bucket consistency
- **Runtime Impact:** Low - no errors, silent data corruption
- **Query Impact:** High - queries assuming `parent.bucket_id == children.bucket_id` will fail

---

## Recommended Remediation

### Option 1: Inherit from Parent in Bucketable

```ruby
# app/models/concerns/bucketable.rb
module Bucketable
  extend ActiveSupport::Concern

  included do
    belongs_to :bucket

    before_validation :set_bucket, on: :create
  end

  private

  def set_bucket
    return if bucket.present?

    if respond_to?(:parent) && parent&.bucket
      self.bucket = parent.bucket
    elsif Current.bucket
      self.bucket = Current.bucket
    else
      raise "Bucket must be set via parent or Current.bucket"
    end
  end
end
```

### Option 2: Enforce in Controller

```ruby
# app/controllers/comments_controller.rb
def create
  @comment_recording = @parent_recording.children.build(
    recordable: Comment.new(comment_params),
    bucket: @parent_recording.bucket  # Explicit inheritance
  )
  # ...
end
```

### Option 3: Add Validation

```ruby
# app/models/recording.rb
validate :bucket_matches_parent, if: :parent

private

def bucket_matches_parent
  if bucket != parent.bucket
    errors.add(:bucket, "must match parent's bucket")
  end
end
```

### Recommended Approach

Combine Options 1 and 3:
1. Auto-inherit in `Bucketable` (fixes the bug)
2. Add validation (prevents future bugs)

### Verification After Fix

```ruby
# In Rails console after fix:
bucket_a = Bucket.create!(name: "Bucket A")
bucket_b = Bucket.create!(name: "Bucket B")

Current.bucket = bucket_a
parent = Recording.create!(recordable: Article.new(title: "Test"))

Current.bucket = bucket_b  # Different bucket
child = parent.children.build(recordable: Comment.new(body: "Test"))
child.save!

child.bucket == parent.bucket  # => true (now inherits from parent)
```

---

## Conclusion

The issue is **confirmed valid**. The `Bucketable` concern should be updated to inherit bucket from parent when present, ensuring tree integrity within a single bucket. This is a data integrity issue that could cause subtle bugs in multi-tenant scenarios.
