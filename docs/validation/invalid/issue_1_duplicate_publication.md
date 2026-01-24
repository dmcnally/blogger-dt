# Validation Report: Issue 1 - Duplicate `has_one :publication`

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** INVALID

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
**Claimed Lines:** 1-18

**Actual code inspection:**

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

  delegated_type :recordable, types: RECORDABLE_TYPES, autosave: true
  # ...
end
```

**Observation:** Line 16 contains `delegated_type :recordable`, NOT `has_one :publication`. There is no direct `has_one :publication` declaration in `recording.rb`.

### Evidence Location 2: Publisher Concern

**File:** `app/models/concerns/publisher.rb`  
**Lines:** 1-10

```ruby
module Publisher
  extend ActiveSupport::Concern

  included do
    has_one :publication, dependent: :destroy

    scope :published, -> { joins(:publication) }
    scope :unpublished, -> { left_joins(:publication).where.missing(:publication) }
  end
```

**Observation:** Line 6 declares `has_one :publication` in the `included` block. This is the ONLY location.

---

## Verification

### Grep Search Results

```bash
grep -rn "has_one :publication" app/
```

**Result:** Only one match found:
- `app/models/concerns/publisher.rb:6`

No duplicate declaration exists in `app/models/recording.rb`.

---

## Conclusion

**Issue Status: INVALID**

The duplicate declaration described in the original report **does not exist** in the current codebase. The `has_one :publication` association is defined only once, in the `Publisher` concern at line 6.

The original report incorrectly claimed that line 16 of `recording.rb` contained `has_one :publication`, but that line actually contains `delegated_type :recordable`.

### Possible Explanations

1. The issue was already fixed before this validation
2. The original analysis was performed on an outdated or different version of the code
3. The original analysis contained an error in locating the code

---

## No Remediation Required

Since the duplicate declaration does not exist, no fix is needed. The codebase is correctly structured with the `has_one :publication` association defined only in the `Publisher` concern.
