# Validation Report: Issue 9 - Publication Doesn't Follow State-as-Recordable Pattern

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** FIXED  
**Severity:** Medium  
**Category:** Architecture Consistency  
**Fixed Date:** January 25, 2026

---

## Issue Hypothesis

The project guidelines specify that states should be represented as child recordables, but `Publication` is implemented as a separate model rather than following this pattern.

---

## Resolution

**Resolution Method:** Guidelines updated to document the Publication pattern as intentional.

The guidelines in `.cursor/rules/models.mdc` have been updated to distinguish between two types of state:

1. **Content State (Recordables)** - For content evolution and versioning, use immutable recordables in the tree (e.g., article revisions, draft versions)

2. **Operational Metadata (Join Models)** - For visibility and access control, use lightweight join models (e.g., `Publication` for published/unpublished state)

### Why Publication Uses a Join Model

The `Publication` model is intentionally designed as a lightweight join model rather than a recordable because:

- **Query efficiency**: Simple `joins(:publication)` enables fast, indexable queries
- **Pagination**: Easy pagination of published content without complex tree queries
- **Separation of concerns**: Publication state is operational metadata (what we DO with content), not content itself (what content IS)
- **Clean recording tree**: The tree remains focused on content relationships, not visibility flags

---

## Original Analysis

### Evidence Location 1: Project Guidelines

**File:** `.cursor/rules/models.mdc`

The guidelines previously stated only:
> Represent state changes as child recordings, NOT as fields on the parent model.

This has been updated to include the "Operational Metadata (Join Models)" section documenting the Publication pattern.

### Evidence Location 2: Publication Model

**File:** `app/models/publication.rb`

```ruby
class Publication < ApplicationRecord
  belongs_to :recording
end
```

This pattern is now documented as the correct approach for operational metadata states.

---

## Affected Files

- `.cursor/rules/models.mdc` - Updated with State Representation section

---

## Verification

```bash
# Verify guidelines document the Publication pattern
grep -A 5 "Operational Metadata" .cursor/rules/models.mdc
```

---

## Conclusion

The issue is **resolved**. The guidelines now document two distinct patterns for state representation, with the `Publication` model serving as the documented example of the operational metadata pattern.
