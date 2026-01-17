# Controller Guidelines

## Overview

This document covers controller patterns, particularly for state recordables and namespacing.

---

## 1. Controller Patterns for State Recordables

Most state recordables (like `Article::Published`) don't warrant full CRUD controllers or dedicated pages. They typically only need simple `create` and `destroy` actions that update a turbo frame.

### Clarify Use Case Before Creating

Before creating a controller for a state recordable, ask:

1. **Does it need its own page?** (Usually no)
2. **What actions are needed?** (Usually just create/destroy)
3. **How will it be used?** (Usually inline toggle, button click → turbo frame update)

### Decision Tree

```
Is this a state recordable (Published, Archived, Featured, etc.)?
├─ Yes
│  └─ Does it need a form with additional data?
│     ├─ No (just toggle on/off)
│     │  └─ Use: Simple toggle pattern (create/destroy only)
│     └─ Yes (needs reason, notes, etc.)
│        └─ Use: Form pattern (new/create/destroy with form)
│
└─ No (data recordable like Article, Profile)
   └─ Does it need its own pages?
      ├─ Yes → Use: Full CRUD controller
      └─ No → Use: Nested controller with limited actions
```

### Common Pattern: Simple Toggle

Most state recordables follow this pattern:

- **No dedicated pages** - state changes happen inline on the parent resource page
- **Only create/destroy actions** - toggling state on/off
- **Turbo frame updates** - respond with updated UI fragment
- **RESTful routes** - use `resource` (singular) with `only: [:create, :destroy]`

---

## 2. Controller Namespacing

Controllers should mirror the model namespace structure. When a child model is specific to a parent, place its controller in an appropriately namespaced folder.

**Rule:** Match controller namespace to model namespace.

### Directory Structure

```
app/
├── models/
│   ├── article/
│   │   ├── published.rb          # Article::Published (model)
│   │   └── archived.rb           # Article::Archived (model)
│   └── article.rb
└── controllers/
    ├── articles/
    │   ├── publications_controller.rb  # Articles::PublicationsController
    │   └── archives_controller.rb      # Articles::ArchivesController
    └── articles_controller.rb          # ArticlesController
```

### Naming Convention

The controller/view name doesn't have to match the model name exactly. Use natural, readable plurals:

| Model | Controller | Reasoning |
|-------|------------|-----------|
| `Article::Published` | `Articles::PublicationsController` | "publications" is natural |
| `Article::Archived` | `Articles::ArchivesController` | "archives" is natural |
| `Article::Featured` | `Articles::FeaturesController` | "features" is natural |
| `Comment::Flagged` | `Comments::FlagsController` | "flags" is natural |

---

## 3. Example: Simple State Toggle

```ruby
# app/controllers/articles/publications_controller.rb
class Articles::PublicationsController < ApplicationController
  before_action :set_article_recording

  def create
    # Create Article::Published recordable and child recording
    published = Article::Published.create!
    @article_recording.children.create!(
      recordable: published,
      recorded_at: Time.current
    )

    respond_to do |format|
      format.turbo_stream # renders app/views/articles/publications/create.turbo_stream.erb
      format.html { redirect_to @article_recording }
    end
  end

  def destroy
    published_recording = @article_recording.children.find_by(recordable_type: 'Article::Published')
    published_recording&.destroy

    respond_to do |format|
      format.turbo_stream # renders app/views/articles/publications/destroy.turbo_stream.erb
      format.html { redirect_to @article_recording }
    end
  end

  private

  def set_article_recording
    @article_recording = Recording.find(params[:article_id])
  end
end
```

### View: Parent Resource Page

```erb
<%# app/views/articles/show.html.erb %>
<%= turbo_frame_tag "article_#{@article.id}_publish_status" do %>
  <% if @article.published? %>
    <span class="badge badge-success">Published</span>
    <%= button_to "Unpublish",
                  article_publication_path(@article),
                  method: :delete %>
  <% else %>
    <span class="badge badge-secondary">Draft</span>
    <%= button_to "Publish",
                  article_publication_path(@article),
                  method: :post %>
  <% end %>
<% end %>
```

### View: Turbo Stream Response

```erb
<%# app/views/articles/publications/create.turbo_stream.erb %>
<%= turbo_stream.replace "article_#{@article_recording.id}_publish_status" do %>
  <%= turbo_frame_tag "article_#{@article_recording.id}_publish_status" do %>
    <span class="badge badge-success">Published</span>
    <%= button_to "Unpublish",
                  article_publication_path(@article_recording),
                  method: :delete %>
  <% end %>
<% end %>
```

---

## 4. Routing

Routes should also be namespaced. Use natural route names that may differ from the controller:

```ruby
# config/routes.rb
resources :articles do
  resource :publication, controller: 'articles/publications', only: [:create, :destroy]
  resource :archive, controller: 'articles/archives', only: [:create, :destroy]
end
```

This generates routes like:

- `POST /articles/:article_id/publication` → `Articles::PublicationsController#create`
- `DELETE /articles/:article_id/publication` → `Articles::PublicationsController#destroy`
- Path helpers: `article_publication_path(@article)`

---

## 5. Benefits

- **Consistency** - controller organization mirrors model organization
- **Discoverability** - easy to find the controller for a namespaced model
- **Clear ownership** - obvious which parent resource the controller belongs to
