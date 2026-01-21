---
name: Article Comment Counts Revised
overview: Add counter infrastructure with atomic increment/decrement operations. Counter concern on Recording, Countable concern on recordables with class-level countable? check and type registry for bulk refresh.
todos: []
---

# Article Comment Counts (Revised)

## Architecture

```mermaid
flowchart TB
subgraph Recording_Layer [