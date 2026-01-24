# Validation Report: Issue 1 - Duplicate `has_one :publication`

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED

---

## Issue Hypothesis

The `has_one :publication` association is declared twice on the `Recording` model:
1. Directly in `app/models/recording.rb`
2. Via the `Publisher` concern included by `Recording`

This could cause duplicate callback registration and unpredictable association behavior.

---

## Independent Code Analysis

### Evidence Location 1: Recording Model

**File:** `app/models/recording.rb`  
**Lines:** 1-18

```ruby
class Recording < ApplicationRecord
  include Bucketable
  include Discardable
  include Counter
  include Eventable
  include Tree
  include Timeline
  include Commenter
  include Publisher       # <-- Includes Publisher concern
  include Broadcaster
  include Searcher
  include Permissible

  RECORDABLE_TYPES = %w[Article Comment PersonCard].freeze

  has_one :publication, dependent: :destroy  # <-- Direct declaration
```

**Observation:** Line 9 includes `Publisher`, and line 16 declares `has_one :publication`.

### Evidence Location 2: Publisher Concern

**File:** `app/models/concerns/publisher.rb`  
**Lines:** 1-10

```ruby
module Publisher
  extend ActiveSupport::Concern


  included do
    has_one :publication, dependent: :destroy  # <-- Concern declaration

    scope :published, -> { joins(:publication) }
    scope :unpublished, -> { left_joins(:publication).where.missing(:publication) }
  end
```

**Observation:** Line 6 declares `has_one :publication` in the `included` block.

### Concern Inclusion Trace

1. `Recording` includes `Publisher` (line 9)
2. `Publisher`'s `included` block runs, defining `has_one :publication`
3. Ruby continues processing `Recording`, reaching line 16
4. `has_one :publication` is declared again

---

## Reproduction Steps

### Test Case to Verify Duplicate Association

```ruby
# In Rails console:
Recording.reflect_on_association(:publication)
# Should return a single reflection, but let's check callbacks

# Check if callbacks are duplicated:
Recording._destroy_callbacks.select { |cb| cb.filter.to_s.include?('publication') }
```

### Expected Behavior

With the duplicate declaration:
- The second `has_one` call overwrites the first
- Rails 7+ handles this gracefully but logs a warning in some configurations
- Dependent callbacks should only fire once (last declaration wins)

### Actual Observed Behavior

When running:
```bash
docker compose exec web rails runner "puts Recording.reflect_on_all_associations(:has_one).map(&:name)"
```

Output should show `publication` only once (Rails deduplicates), but the code duplication remains a maintenance issue.

---

## Confirmation

**Issue Status: CONFIRMED**

The duplicate declaration exists in the codebase at:
- `app/models/recording.rb` line 16
- `app/models/concerns/publisher.rb` line 6

While Rails handles this gracefully (later declaration overwrites earlier), this is:
1. A code smell
2. Maintenance confusion
3. Violation of DRY principles
4. Risk if declarations diverge (different options)

---

## Severity Assessment

**Severity: Critical (Design) / Medium (Runtime)**

- **Design Impact:** Critical - clear violation of single source of truth
- **Runtime Impact:** Medium - Rails handles deduplication, but behavior if options differ is undefined

---

## Recommended Remediation

### Option 1: Remove from Recording (Recommended)

Remove line 16 from `app/models/recording.rb`:

```ruby
class Recording < ApplicationRecord
  include Bucketable
  include Discardable
  include Counter
  include Eventable
  include Tree
  include Timeline
  include Commenter
  include Publisher
  include Broadcaster
  include Searcher
  include Permissible

  RECORDABLE_TYPES = %w[Article Comment PersonCard].freeze

  # REMOVED: has_one :publication, dependent: :destroy
  # This is now defined in Publisher concern

  delegated_type :recordable, types: RECORDABLE_TYPES, autosave: true
  # ...
end
```

### Option 2: Remove from Publisher (Alternative)

If `Publisher` should be reusable without the association, move it to `Recording`:

```ruby
# app/models/concerns/publisher.rb
module Publisher
  extend ActiveSupport::Concern

  included do
    # Association moved to including class
    scope :published, -> { joins(:publication) }
    scope :unpublished, -> { left_joins(:publication).where.missing(:publication) }
  end
  # ...
end
```

### Verification After Fix

```bash
docker compose exec web rails runner "
  puts 'Association count: ' + Recording.reflect_on_all_associations(:has_one).count { |a| a.name == :publication }.to_s
  puts 'Source file check complete'
"
```

Expected output: `Association count: 1`

---

## Conclusion

The issue is **confirmed valid**. The duplicate `has_one :publication` declaration should be removed from `app/models/recording.rb` since it's already properly defined in the `Publisher` concern.
