# Validation Report: Issue 7 - Tree Recursion Causes N+1 Queries

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** CONFIRMED  
**Severity:** Medium  
**Category:** Concern Design / Performance

---

## Issue Hypothesis

The `Tree` concern uses recursive method calls that generate N+1 queries, causing performance degradation with tree depth/breadth.

---

## Independent Code Analysis

### Evidence Location: Tree Concern

**File:** `app/models/concerns/tree.rb`  
**Lines:** 17-27

```ruby
def root
  root? ? self : parent.root
end

def ancestors
  return [] if root?
  [ parent ] + parent.ancestors
end

def descendants
  children.flat_map { |child| [ child ] + child.descendants }
end
```

**Observation:** Each method uses Ruby recursion, triggering a database query at each level of the tree.

---

## Impact

- `root`: N database queries for N-level deep tree
- `ancestors`: N queries to traverse up
- `descendants`: Exponential queries for wide trees
- Performance degrades with tree depth/breadth

---

## Affected Files

- `app/models/concerns/tree.rb`

---

## Confirmation

**Issue Status: CONFIRMED**

The recursive pattern exists in the codebase and will generate N+1 queries proportional to tree depth/breadth.

---

## Severity Assessment

**Severity: Medium**

- **Design Impact:** Medium - functional but inefficient
- **Runtime Impact:** Medium to High - depends on tree size

---

## Recommended Remediation

Use PostgreSQL recursive CTEs for single-query traversal:

```ruby
def ancestors
  return [] if root?

  Recording.find_by_sql([<<~SQL, id, id])
    WITH RECURSIVE tree AS (
      SELECT * FROM recordings WHERE id = ?
      UNION ALL
      SELECT r.* FROM recordings r
      INNER JOIN tree t ON r.id = t.parent_id
    )
    SELECT * FROM tree WHERE id != ?
    ORDER BY id
  SQL
end

def descendants
  return [] if children.empty?

  Recording.find_by_sql([<<~SQL, id, id])
    WITH RECURSIVE tree AS (
      SELECT * FROM recordings WHERE parent_id = ?
      UNION ALL
      SELECT r.* FROM recordings r
      INNER JOIN tree t ON r.parent_id = t.id
    )
    SELECT * FROM tree
    ORDER BY id
  SQL
end
```

### Verification After Fix

```bash
docker compose exec web rails runner "
  # Check that tree methods work correctly
  recording = Recording.first
  puts 'Ancestors: ' + recording.ancestors.count.to_s
  puts 'Descendants: ' + recording.descendants.count.to_s
"
```

---

## Conclusion

The issue is **confirmed valid**. The recursive tree traversal should be replaced with PostgreSQL recursive CTEs for better performance at scale.
