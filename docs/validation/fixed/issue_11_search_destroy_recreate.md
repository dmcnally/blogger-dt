# Validation Report: Issue 11 - Search Index Destroy/Recreate Pattern

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** FIXED  
**Severity:** Low  
**Category:** Performance  
**Resolution Date:** January 25, 2026

---

## Issue Hypothesis

The `Searcher` concern uses a destroy/recreate pattern for updating search indices, which is less efficient than an upsert operation.

---

## Independent Code Analysis

### Evidence Location: Searcher Concern

**File:** `app/models/concerns/searcher.rb`  
**Lines:** 25-30

```ruby
def update_search_index
  search_index&.destroy
  create_search_index!(
    recordable_type: recordable_type,
    content: recordable.searchable_content
  )
end
```

**Observation:** The method first destroys the existing search index, then creates a new one. This results in two database operations instead of one.

---

## Impact

- Two database operations instead of one
- Brief window where search index doesn't exist
- Slightly higher database load
- Potential race condition during the gap

---

## Affected Files

- `app/models/concerns/searcher.rb`

---

## Confirmation

**Issue Status: CONFIRMED**

The destroy/recreate pattern exists in the `Searcher` concern.

---

## Severity Assessment

**Severity: Low**

- **Design Impact:** Low - functional but suboptimal
- **Runtime Impact:** Low - minor performance overhead

---

## Recommended Remediation

Use upsert for atomic single-query update:

```ruby
def update_search_index
  SearchIndex.upsert(
    {
      recording_id: id,
      recordable_type: recordable_type,
      content: recordable.searchable_content
    },
    unique_by: :recording_id
  )
  reload_search_index
end
```

**Note:** This requires a unique index on `recording_id` in the `search_indices` table.

### Verification After Fix

```bash
docker compose exec web rails runner "
  recording = Recording.first
  recording.update_search_index
  puts 'Search index exists: ' + recording.search_index.present?.to_s
"
```

---

## Resolution

The `update_search_index` method was refactored to use `upsert` with `unique_by: :recording_id`:

```ruby
def update_search_index
  SearchIndex.upsert(
    {
      recording_id: id,
      recordable_type: recordable_type,
      content: recordable.searchable_content
    },
    unique_by: :recording_id
  )
  association(:search_index).reload
end
```

**Benefits:**
- Single atomic database operation instead of two
- No gap where search index doesn't exist
- Eliminates potential race conditions
- Preserves the same record ID (row updated in place)

**Test updates:**
- Updated test "destroys old search_index when recordable changes" to "keeps same search_index record when recordable changes" to reflect the new behavior

---

## Conclusion

The issue has been **fixed**. The destroy/recreate pattern was replaced with an atomic upsert operation.
