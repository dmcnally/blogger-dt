# Validation Report: Issue 13 - Orphan Recordables Accumulate

**Validation Date:** January 24, 2026  
**Validator:** Independent Code Analysis Agent  
**Status:** INVALID  
**Category:** Data Management

---

## Issue Hypothesis

Due to the immutability pattern, when a recording is updated, a new recordable is created but the old one remains in the database, causing gradual accumulation of orphaned rows.

---

## Why This Is Invalid

**The recordables are not orphaned.** While they are no longer referenced by their original Recording, they remain referenced by Events as the subject of the change.

The immutability pattern is intentional:

1. Recording A has `recordable_id: 1` pointing to Article 1
2. User updates the article
3. Article 2 is created with new content
4. Recording A is updated to `recordable_id: 2`
5. An Event is created with Article 1 as the subject, preserving the audit trail

This design enables:
- **Full audit history** - Events reference the exact recordable version at the time of change
- **Point-in-time reconstruction** - Can see exactly what content existed when an event occurred
- **Immutable event subjects** - Event records remain accurate even as recordings evolve

---

## Conclusion

The issue is **invalid**. The "orphaned" recordables are intentionally preserved and referenced by events as subjects, providing a complete audit trail of content changes over time.
