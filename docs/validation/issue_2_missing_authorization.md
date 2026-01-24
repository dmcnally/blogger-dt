# Validation Report: Issue 2 - Missing Authorization Enforcement

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED

---

## Issue Hypothesis

The application has a permission system (`Permissible` concern with `editable_by?`, `deletable_by?`, `viewable_by?` methods) but controllers do not enforce these permissions, allowing any authenticated user to modify any content.

---

## Independent Code Analysis

### Evidence Location 1: Permissible Concern Exists

**File:** `app/models/concerns/permissible.rb`  
**Lines:** 1-16

```ruby
module Permissible
  extend ActiveSupport::Concern

  def editable_by?(person)
    recordable.editable_by?(person)
  end

  def deletable_by?(person)
    recordable.deletable_by?(person)
  end

  def viewable_by?(person)
    recordable.viewable_by?(person)
  end
end
```

**Observation:** The concern delegates to recordable's permission methods.

### Evidence Location 2: Article Implements Permissions

**File:** `app/models/article.rb`  
**Lines:** 20-31

```ruby
# Permission methods
def editable_by?(person)
  person.editor_of?(recording.bucket)
end

def deletable_by?(person)
  person.admin_of?(recording.bucket) || recording.creator == person
end

def viewable_by?(person)
  person.viewer_of?(recording.bucket)
end
```

**Observation:** Article has role-based permission logic that checks bucket membership.

### Evidence Location 3: Recording Includes Permissible

**File:** `app/models/recording.rb`  
**Line:** 12

```ruby
include Permissible
```

**Observation:** Recordings expose permission methods.

### Evidence Location 4: ArticlesController - No Authorization

**File:** `app/controllers/articles_controller.rb`  
**Full analysis:**

```ruby
class ArticlesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_recording, only: [ :show, :edit, :update, :destroy ]

  # ...

  def update
    # NO PERMISSION CHECK - any authenticated user can update
    @recording.recordable = Article.new(article_params)

    if @recording.save
      redirect_to @recording, notice: "Article was successfully updated."
    else
      # ...
    end
  end

  def destroy
    # NO PERMISSION CHECK - any authenticated user can delete
    @recording.discard!
    redirect_to articles_path, notice: "Article was successfully deleted.", status: :see_other
  end
```

**Missing:** No calls to `@recording.editable_by?(Current.person)` or `@recording.deletable_by?(Current.person)`.

### Evidence Location 5: PublicationsController - No Authorization

**File:** `app/controllers/publications_controller.rb`  
**Full analysis:**

```ruby
class PublicationsController < ApplicationController
  before_action :set_recording

  def create
    # NO PERMISSION CHECK
    @recording.publish!
    # ...
  end

  def destroy
    # NO PERMISSION CHECK
    @recording.unpublish!
    # ...
  end
```

**Missing:** No verification that `Current.person` can publish/unpublish this recording.

### Evidence Location 6: CommentsController - No Authorization

**File:** `app/controllers/comments_controller.rb`  
**Lines:** 23-29

```ruby
def destroy
  # NO PERMISSION CHECK
  @comment_recording.discard!
  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to @parent_recording, notice: "Comment was successfully deleted.", status: :see_other }
  end
end
```

**Missing:** No call to `@comment_recording.deletable_by?(Current.person)`.

---

## Reproduction Steps

### Manual Test Case

1. Create two users with different people in different buckets
2. User A creates an article in Bucket A
3. Log in as User B (member of Bucket B only)
4. Attempt to edit/delete User A's article via direct URL
5. **Expected:** Access denied
6. **Actual:** Article is modified/deleted

### Automated Test Case

```ruby
# test/controllers/articles_controller_authorization_test.rb
require "test_helper"

class ArticlesControllerAuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @bucket_a = Bucket.create!(name: "Bucket A")
    @bucket_b = Bucket.create!(name: "Bucket B")
    
    @person_a = create_person_in_bucket(@bucket_a, :admin)
    @person_b = create_person_in_bucket(@bucket_b, :admin)
    
    Current.bucket = @bucket_a
    Current.person = @person_a
    @article_recording = Recording.create!(recordable: Article.new(title: "Test"))
  end

  test "user cannot update article in bucket they don't belong to" do
    Current.person = @person_b
    Current.bucket = @bucket_b
    
    patch article_url(@article_recording), params: { article: { title: "Hacked" } }
    
    # SHOULD redirect with error, but currently succeeds
    assert_response :redirect  # This passes incorrectly
  end
end
```

---

## Confirmation

**Issue Status: CONFIRMED**

The authorization gap exists in all three controllers:

| Controller | Action | Permission Method | Status |
|------------|--------|-------------------|--------|
| ArticlesController | edit | `editable_by?` | NOT CALLED |
| ArticlesController | update | `editable_by?` | NOT CALLED |
| ArticlesController | destroy | `deletable_by?` | NOT CALLED |
| PublicationsController | create | - | NOT CALLED |
| PublicationsController | destroy | - | NOT CALLED |
| CommentsController | destroy | `deletable_by?` | NOT CALLED |

---

## Severity Assessment

**Severity: Critical (Security)**

- **Security Impact:** Critical - any authenticated user can modify any content
- **Data Integrity Impact:** Critical - unauthorized modifications possible
- **Compliance Impact:** High - violates principle of least privilege

---

## Recommended Remediation

### Step 1: Add Authorization Helper to ApplicationController

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  
  private

  def authorize!(permission_method)
    unless @recording&.send(permission_method, Current.person)
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You are not authorized to perform this action." }
        format.turbo_stream { head :forbidden }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def authorize_edit!
    authorize!(:editable_by?)
  end

  def authorize_delete!
    authorize!(:deletable_by?)
  end

  def authorize_view!
    authorize!(:viewable_by?)
  end
end
```

### Step 2: Update ArticlesController

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_recording, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_view!, only: [ :show ]
  before_action :authorize_edit!, only: [ :edit, :update ]
  before_action :authorize_delete!, only: [ :destroy ]

  # ... rest of controller
end
```

### Step 3: Update PublicationsController

```ruby
# app/controllers/publications_controller.rb
class PublicationsController < ApplicationController
  before_action :set_recording
  before_action :authorize_edit!  # Publishing requires edit permission

  # ... rest of controller
end
```

### Step 4: Update CommentsController

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_parent_recording
  before_action :set_comment_recording, only: [ :destroy ]
  before_action :authorize_comment_delete!, only: [ :destroy ]

  private

  def authorize_comment_delete!
    unless @comment_recording.deletable_by?(Current.person)
      redirect_to @parent_recording, alert: "You cannot delete this comment."
    end
  end
end
```

### Verification After Fix

```ruby
# test/controllers/articles_controller_test.rb
test "unauthorized user cannot update article" do
  sign_in_as(@unauthorized_user)
  
  patch article_url(@recording), params: { article: { title: "Hacked" } }
  
  assert_redirected_to root_path
  assert_equal "You are not authorized to perform this action.", flash[:alert]
  assert_equal "Original Title", @recording.reload.recordable.title
end
```

---

## Conclusion

The issue is **confirmed valid and critical**. The permission system exists but is not enforced. All modifying controller actions require authorization checks before proceeding.
