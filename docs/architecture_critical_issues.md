# Critical Architecture Issues

**Generated:** January 24, 2026  
**Priority:** Top 5 Most Critical Issues

This document contains the 5 most critical architectural issues identified in the application. These issues were selected based on:
- Impact on application correctness
- Risk of runtime errors
- Violation of documented architecture guidelines
- Security implications

---

## Issue 1: Duplicate `has_one :publication` Declaration

**ID:** ISSUE-001  
**Severity:** Critical  
**Category:** Model Layer

### Description

The `has_one :publication` association is declared in two places:

**Recording model** (`app/models/recording.rb` line 16):
```ruby
has_one :publication, dependent: :destroy
```

**Publisher concern** (`app/models/concerns/publisher.rb` line 6):
```ruby
has_one :publication, dependent: :destroy
```

Since `Recording` includes `Publisher` (line 9), the association is defined twice on the same model.

### Impact

- Rails may register duplicate callbacks for the association
- Association behavior may be unpredictable
- The `dependent: :destroy` callback could potentially fire twice
- Maintenance confusion about the source of truth

### Affected Files

- `app/models/recording.rb`
- `app/models/concerns/publisher.rb`

### Recommended Fix

Remove line 16 from `app/models/recording.rb`:
```ruby
# Remove this line - already defined in Publisher concern
has_one :publication, dependent: :destroy
```

---

## Issue 2: Missing Authorization Enforcement in Controllers

**ID:** ISSUE-004  
**Severity:** Critical  
**Category:** Controller Layer / Security

### Description

The application has a well-designed permission system via the `Permissible` concern, but controllers do not enforce these permissions.

**Permissible concern** (`app/models/concerns/permissible.rb`):
```ruby
def editable_by?(person)
  recordable.editable_by?(person)
end

def deletable_by?(person)
  recordable.deletable_by?(person)
end

def viewable_by?(person)
  recordable.viewable_by?(person)
end
```

**Unprotected controllers:**

1. `PublicationsController` - publish/unpublish without permission check
2. `ArticlesController#update` - edit without permission check
3. `ArticlesController#destroy` - delete without permission check
4. `CommentsController#destroy` - delete without permission check

### Impact

- **Security vulnerability:** Any authenticated user can modify any content
- Authorization system exists but is not used
- Bucket-based multi-tenancy permissions are bypassed

### Affected Files

- `app/controllers/publications_controller.rb`
- `app/controllers/articles_controller.rb`
- `app/controllers/comments_controller.rb`

### Recommended Fix

Add authorization helper to `ApplicationController`:
```ruby
class ApplicationController < ActionController::Base
  private

  def authorize!(permission_method)
    unless @recording.send(permission_method, Current.person)
      redirect_to root_path, alert: "Not authorized"
    end
  end
end
```

Use in controllers:
```ruby
class ArticlesController < ApplicationController
  before_action :authorize_edit, only: [:edit, :update]
  before_action :authorize_delete, only: [:destroy]

  private

  def authorize_edit
    authorize!(:editable_by?)
  end

  def authorize_delete
    authorize!(:deletable_by?)
  end
end
```

---

## Issue 3: Redundant Concern Includes in Recordable Models

**ID:** ISSUE-002  
**Severity:** High  
**Category:** Model Layer / Concern Design

### Description

Both `Article` and `Comment` explicitly include concerns that are already included via `Recordable`.

**Recordable concern** (`app/models/concerns/recordable.rb` lines 4-13):
```ruby
included do
  has_one :recording, as: :recordable, touch: true

  include Broadcastable
  include Commentable
  include Countable
  include Describable
  include Immutable
  include Publishable
  include Searchable
end
```

**Article model** (`app/models/article.rb` lines 2-4):
```ruby
include Recordable
include Describable  # Already in Recordable
include Searchable   # Already in Recordable
```

**Comment model** (`app/models/comment.rb` lines 2-6):
```ruby
include Recordable
include Broadcastable  # Already in Recordable
include Countable      # Already in Recordable
include Describable    # Already in Recordable
include Searchable     # Already in Recordable
```

### Impact

- **Pattern interference:** The concern specialization pattern relies on Ruby's constant lookup. Explicit includes of `::Describable` may prevent `Article::Describable` from being resolved correctly.
- Maintenance confusion about which concerns are actually applied
- Violates DRY principles

### Affected Files

- `app/models/article.rb`
- `app/models/comment.rb`
- `app/models/concerns/recordable.rb`

### Recommended Fix

Remove redundant includes from models:

**Article:**
```ruby
class Article < ApplicationRecord
  include Recordable
  # Describable and Searchable are included via Recordable
  # Article::Describable and Article::Searchable specialize them

  validates :title, presence: true
  # ...
end
```

**Comment:**
```ruby
class Comment < ApplicationRecord
  include Recordable
  # All other concerns are included via Recordable
  # Comment::* modules specialize them

  validates :body, presence: true
  # ...
end
```

---

## Issue 4: Child Recordings Don't Inherit Bucket from Parent

**ID:** ISSUE-006  
**Severity:** High  
**Category:** Concern Design / Data Integrity

### Description

The `Bucketable` concern sets bucket from `Current.bucket` only, ignoring the parent recording's bucket.

**Bucketable concern** (`app/models/concerns/bucketable.rb` lines 10-17):
```ruby
def set_bucket_from_current
  return if bucket.present?

  raise "Current.bucket must be set" unless Current.bucket

  self.bucket = Current.bucket
end
```

**CommentsController** creates child recordings (`app/controllers/comments_controller.rb` lines 6-8):
```ruby
@comment_recording = @parent_recording.children.build(
  recordable: Comment.new(comment_params)
)
```

### Impact

- If `Current.bucket` differs from parent's bucket (due to bug, race condition, or misconfiguration), child recordings end up in wrong bucket
- Tree hierarchy bucket consistency is not enforced at the model level
- Relies entirely on controller-level `Current.bucket` being correct

### Affected Files

- `app/models/concerns/bucketable.rb`
- `app/controllers/comments_controller.rb`

### Recommended Fix

Modify `Bucketable` to inherit from parent:

```ruby
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

---

## Issue 5: Broadcast Method Name Mismatch

**ID:** ISSUE-003  
**Severity:** High  
**Category:** Concern Design / Runtime Error

### Description

The `Broadcaster` concern calls `broadcast_on_discard`, but `Comment::Broadcastable` defines `broadcast_on_destroy`.

**Broadcaster concern** (`app/models/concerns/broadcaster.rb` lines 14-17):
```ruby
def broadcast_recordable_discard
  recordable.broadcast_on_discard(self) if recordable.broadcastable?
end
```

**Base Broadcastable concern** (`app/models/concerns/broadcastable.rb` lines 13-15):
```ruby
def broadcast_on_discard(recording)
  # Override in recordable to broadcast on discard
end
```

**Comment::Broadcastable** (`app/models/comment/broadcastable.rb` lines 19-24):
```ruby
def broadcast_on_destroy(recording)  # Wrong method name!
  Turbo::StreamsChannel.broadcast_remove_to(
    recording.parent, "comments",
    target: ActionView::RecordIdentifier.dom_id(recording)
  )
end
```

### Impact

- When a comment is discarded, `broadcast_on_discard` is called
- The method exists (empty implementation in base concern) so no error is raised
- But `broadcast_on_destroy` is never called
- **UI Bug:** Discarded comments are not removed from the page via Turbo Streams

### Affected Files

- `app/models/concerns/broadcaster.rb`
- `app/models/concerns/broadcastable.rb`
- `app/models/comment/broadcastable.rb`

### Recommended Fix

Rename the method in `Comment::Broadcastable`:

```ruby
module Comment::Broadcastable
  extend ActiveSupport::Concern

  include ::Broadcastable

  def broadcastable?
    true
  end

  def broadcast_on_create(recording)
    # ... existing implementation
  end

  def broadcast_on_discard(recording)  # Renamed from broadcast_on_destroy
    Turbo::StreamsChannel.broadcast_remove_to(
      recording.parent, "comments",
      target: ActionView::RecordIdentifier.dom_id(recording)
    )
  end
end
```

---

## Summary

| Priority | Issue | Severity | Type |
|----------|-------|----------|------|
| 1 | Duplicate `has_one :publication` | Critical | Bug |
| 2 | Missing authorization enforcement | Critical | Security |
| 3 | Redundant concern includes | High | Design |
| 4 | Child bucket inheritance | High | Data Integrity |
| 5 | Broadcast method mismatch | High | Bug |

All five issues require immediate attention. Issues 1, 2, and 5 are bugs that affect runtime behavior. Issues 3 and 4 are design problems that could lead to subtle bugs.
