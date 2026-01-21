---
name: Extract Immutable Concern
overview: Extract the immutability callbacks from Recordable into a new Immutable concern, then include it in Recordable.
todos:
  - id: create-immutable
    content: Create `app/models/concerns/immutable.rb` with before_update and before_destroy callbacks
    status: completed
  - id: update-recordable
    content: Update Recordable to include Immutable instead of inline callbacks
    status: completed
---

# Extract Immutable Concern

## Current State

The [`app/models/concerns/recordable.rb`](app/models/concerns/recordable.rb) concern contains two callbacks that enforce immutability:

```11:13:app/models/concerns/recordable.rb
    # Enforce immutability
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
```

## Changes

### 1. Create `app/models/concerns/immutable.rb`

New concern with the extracted callbacks:

```ruby
module Immutable
  extend ActiveSupport::Concern

  included do
    before_update { raise ActiveRecord::ReadOnlyRecord }
    before_destroy { raise ActiveRecord::ReadOnlyRecord }
  end
end
```

### 2. Update `app/models/concerns/recordable.rb`

Replace the inline callbacks with an include:

```ruby
module Recordable
  extend ActiveSupport::Concern

  included do
    include Broadcastable
    include Commentable
    include Describable
    include Immutable
    include Publishable
    include Searchable
  end
end
```

## Impact

No functional changes. The 4 models using Recordable (Article, Comment, PersonCard, PublicationState) will continue to be immutable. The new `Immutable` concern can also be included independently by other models that need immutability without the full Recordable behavior.