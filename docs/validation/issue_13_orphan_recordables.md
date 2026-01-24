# Validation Report: Issue 13 - Orphan Recordables Accumulate

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED  
**Severity:** Low  
**Category:** Data Management

---

## Issue Hypothesis

Due to the immutability pattern, when a recording is updated, a new recordable is created but the old one remains in the database, causing gradual accumulation of orphaned rows.

---

## Independent Code Analysis

### Evidence Location: ArticlesController Update

**File:** `app/controllers/articles_controller.rb`  
**Lines:** 35-37

```ruby
@recording.recordable = Article.new(article_params)
```

**Observation:** When updating, a new `Article` is created and assigned. The old `Article` row is orphaned (no recording points to it anymore).

### Pattern Explanation

1. Recording A has `recordable_id: 1` pointing to Article 1
2. User updates the article
3. Article 2 is created with new content
4. Recording A is updated to `recordable_id: 2`
5. Article 1 is now orphaned (no recording references it)

---

## Impact

- Gradual database growth from orphaned rows
- No cleanup mechanism exists
- Could affect backup/restore times
- Storage costs increase over time

---

## Affected Files

- `app/controllers/articles_controller.rb`
- `app/controllers/comments_controller.rb` (similar pattern)
- Any controller that updates recordables

---

## Confirmation

**Issue Status: CONFIRMED**

The immutability pattern creates orphaned recordables with no cleanup mechanism.

---

## Severity Assessment

**Severity: Low**

- **Design Impact:** Low - may be intentional for audit trail
- **Runtime Impact:** Low - gradual accumulation over time

---

## Recommended Remediation

### Option 1: Accept as Intentional (Audit Trail)

If orphaned recordables serve as an audit trail, document this:

```ruby
# app/controllers/articles_controller.rb
# Note: Old recordable is intentionally preserved for audit trail.
# See docs/architecture.md for cleanup schedule.
@recording.recordable = Article.new(article_params)
```

### Option 2: Add Background Cleanup Job

Create a job to periodically clean up orphaned recordables:

```ruby
# app/jobs/cleanup_orphaned_recordables_job.rb
class CleanupOrphanedRecordablesJob < ApplicationJob
  queue_as :low_priority

  def perform
    cleanup_orphaned(Article)
    cleanup_orphaned(Comment)
    # Add other recordable types as needed
  end

  private

  def cleanup_orphaned(klass)
    orphaned = klass.where.not(
      id: Recording.where(recordable_type: klass.name).select(:recordable_id)
    )
    
    Rails.logger.info "Cleaning up #{orphaned.count} orphaned #{klass.name} records"
    orphaned.delete_all
  end
end
```

Schedule in `config/recurring.yml`:

```yaml
cleanup_orphaned_recordables:
  class: CleanupOrphanedRecordablesJob
  schedule: every week at 3am
```

### Option 3: Clean Up on Update

Delete the old recordable when updating:

```ruby
def update
  old_recordable = @recording.recordable
  @recording.recordable = Article.new(article_params)
  
  if @recording.save
    old_recordable.destroy
    # ...
  end
end
```

### Verification After Fix

```bash
docker compose exec web rails runner "
  orphaned_articles = Article.where.not(id: Recording.where(recordable_type: 'Article').select(:recordable_id))
  puts 'Orphaned articles: ' + orphaned_articles.count.to_s
"
```

---

## Conclusion

The issue is **confirmed valid**. Either document the orphaned recordables as intentional for audit purposes, or implement a cleanup mechanism to prevent database growth.
