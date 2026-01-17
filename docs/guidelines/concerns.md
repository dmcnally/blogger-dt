# Concern Guidelines

## Overview

This document covers how to organize and structure concerns in Rails applications.

---

## 1. Model Organization with Concerns

### Directory Structure

```
app/models/
├── concerns/                    # Shared concerns (2+ models)
│   ├── recordable.rb
│   └── sluggable.rb
├── post/                        # Post-specific concerns
│   ├── publishing.rb            # Post::Publishing
│   └── moderation.rb            # Post::Moderation
├── user/                        # User-specific concerns
│   ├── authentication.rb        # User::Authentication
│   └── authorization.rb         # User::Authorization
├── post.rb
└── user.rb
```

### Placement Rules

| Location | When to Use |
|----------|-------------|
| `app/models/concerns/` | Shared by 2+ models |
| `app/models/model_name/` | Specific to one model |

### What Belongs in a Concern

- Related callbacks and validations
- Scopes that share a common purpose
- Instance methods that form a cohesive feature
- Class methods related to a specific capability

### What Does NOT Belong in a Concern

- Business logic that should be in a service object
- Unrelated methods grouped together
- Code that's only used once (keep it in the model)

---

## 2. Specializing General Concerns

When a model needs to specialize behavior from a general concern, namespace the specialization under the model. This leverages Ruby's constant lookup to create a clean inheritance chain.

### Pattern

1. **General concern** lives in `app/models/concerns/`
2. **Specialized concern** lives under the model namespace in `app/models/model_name/`
3. **Model includes** the concern name without namespace
4. **Ruby resolves** to the namespaced version first
5. **Specialized concern includes** the general version with `::` prefix

### Example Structure

```
app/models/
├── concerns/
│   └── eventable.rb              # ::Eventable (general)
├── article/
│   └── eventable.rb              # Article::Eventable (specialized)
└── article.rb
```

### Implementation

```ruby
# app/models/concerns/eventable.rb
# General concern with base behavior
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  def track_event(action, **details)
    events.create!(action: action, details: details)
  end
end

# app/models/article/eventable.rb
# Specialized concern for Article
module Article::Eventable
  extend ActiveSupport::Concern

  # Include the general concern to get base behavior
  include ::Eventable

  # Add Article-specific event tracking
  def track_publication(published_by:)
    track_event(:published, published_by: published_by, published_at: Time.current)
  end

  def track_unpublication(unpublished_by:)
    track_event(:unpublished, unpublished_by: unpublished_by, unpublished_at: Time.current)
  end
end

# app/models/article.rb
class Article < ApplicationRecord
  # Ruby's constant lookup resolves this to Article::Eventable first
  # which in turn includes ::Eventable
  include Eventable
end
```

### How Constant Resolution Works

When `Article` includes `Eventable`, Ruby looks for constants in this order:

1. `Article::Eventable` (found! uses the specialized version)
2. If not found, would look for `::Eventable` (general version)

Since `Article::Eventable` includes `::Eventable`, the article gets both the general behavior and its specializations.

### Benefits

- **Clean model code** - model just says `include Eventable`, no special syntax
- **Discoverable** - specialized concerns live alongside other model-specific code
- **Composable** - can layer multiple concerns this way
- **No conflicts** - specialized and general concerns coexist naturally
- **Explicit inheritance** - `include ::Eventable` makes the relationship clear

### When to Use

| Use Specialization | Use Separate Concern |
|-------------------|---------------------|
| Extending general behavior for one model | Completely different behavior |
| Model needs extra methods on shared concern | No relationship to existing concern |
| Want to leverage constant resolution | Multiple models need the variation |

---

## 3. Real-World Example: Recording::Eventable

The `Recording` model has specialized event tracking:

### Structure

```
app/models/
├── concerns/
│   └── eventable.rb              # General event tracking
├── recording/
│   └── eventable.rb              # Recording::Eventable
└── recording.rb
```

### Implementation

```ruby
# app/models/recording/eventable.rb
module Recording::Eventable
  extend ActiveSupport::Concern

  include ::Eventable  # Gets base event tracking

  # Add Recording-specific tracking with recordable context
  included do
    after_create :track_created
    after_update :track_updated
  end

  def track_created
    track_event(:created, recordable_type: recordable_type, recordable_id: recordable_id)
  end

  def track_updated
    track_event(:updated,
      recordable_type: recordable_type,
      recordable_id: recordable_id,
      recordable_previous_id: recordable_id_was)
  end
end
```

---

## 4. Naming Conventions

### Concern Names

- Use adjectives or nouns that describe the capability
- Examples: `Recordable`, `Sluggable`, `Eventable`, `Publishable`

### Namespaced Concerns

- Use the model name as the namespace
- The concern name should match the general concern it specializes (if any)
- Examples: `Article::Eventable`, `Recording::Eventable`, `User::Authentication`

### File Naming

- Use snake_case for file names
- Match the class/module name
- Examples: `eventable.rb`, `authentication.rb`

---

## 5. Promoting Concerns

When to promote a model-specific concern to shared:

1. **Second use case appears** - when another model needs similar behavior
2. **Extract commonality** - pull out the shared parts, keep model-specific parts namespaced
3. **Don't pre-optimize** - start model-specific, promote when needed

### Promotion Process

1. Identify shared behavior
2. Create general concern in `app/models/concerns/`
3. Update original model-specific concern to include general concern
4. Create new model-specific concern that includes general concern
5. Both models now have general + specific behavior
