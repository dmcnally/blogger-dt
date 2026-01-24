# Validation Report: Issue 9 - Publication Doesn't Follow State-as-Recordable Pattern

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED  
**Severity:** Medium  
**Category:** Architecture Consistency

---

## Issue Hypothesis

The project guidelines specify that states should be represented as child recordables, but `Publication` is implemented as a separate model rather than following this pattern.

---

## Independent Code Analysis

### Evidence Location 1: Project Guidelines

**File:** `.cursor/rules/models.mdc`

> Represent state changes as child recordings, NOT as fields on the parent model.
> Create state recordables as children in the recording tree.

### Evidence Location 2: Publication Model

**File:** `app/models/publication.rb`

```ruby
class Publication < ApplicationRecord
  belongs_to :recording
end
```

**Observation:** `Publication` is a standalone model with a direct association to `Recording`, rather than being a recordable in the recording tree.

### Expected Pattern (Per Guidelines)

```ruby
class Article::Published < ApplicationRecord
  include Recordable
end
```

---

## Impact

- Inconsistency with documented architecture
- Publication isn't tracked in the recording tree
- Different query patterns required for publication vs other states
- May confuse developers expecting consistent patterns

---

## Affected Files

- `app/models/publication.rb`
- `app/models/concerns/publisher.rb`
- `.cursor/rules/models.mdc`

---

## Confirmation

**Issue Status: CONFIRMED**

The `Publication` model doesn't follow the state-as-recordable pattern documented in the project guidelines.

---

## Severity Assessment

**Severity: Medium**

- **Design Impact:** Medium - inconsistency with documented architecture
- **Runtime Impact:** Low - functionally correct

---

## Recommended Remediation

### Option 1: Update Guidelines (Recommended if Current Design is Intentional)

Document `Publication` as an intentional pattern for simple boolean states:

```markdown
## State Representation

### Complex States
Represent state changes as child recordings using the recordable pattern.

### Simple Boolean States
For simple published/unpublished states, use the `Publication` model pattern
which provides a lighter-weight approach without full recording tree integration.
```

### Option 2: Refactor to State-as-Recordable Pattern

Refactor `Publication` to follow the documented pattern:

1. Create `Article::Published` recordable
2. Update `Publisher` concern to create recording children
3. Update queries to use recording tree

### Verification After Fix

If Option 1:
```bash
# Verify guidelines are updated
grep -l "Publication" .cursor/rules/models.mdc
```

If Option 2:
```bash
docker compose exec web rails runner "
  puts 'Published recordable exists: ' + defined?(Article::Published).to_s
"
```

---

## Conclusion

The issue is **confirmed valid**. Either update the guidelines to document the `Publication` pattern as intentional, or refactor to use the state-as-recordable pattern for consistency.
