# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_21_080925) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.string "title", null: false
  end

  create_table "buckets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
  end

  create_table "counter_caches", force: :cascade do |t|
    t.integer "count", default: 0, null: false
    t.bigint "counterable_id", null: false
    t.string "counterable_type", null: false
    t.string "name", null: false
    t.index ["counterable_type", "counterable_id", "name"], name: "index_counter_caches_uniqueness", unique: true
    t.index ["counterable_type", "counterable_id"], name: "index_counter_caches_on_counterable"
  end

  create_table "event_details", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "key", null: false
    t.text "value"
    t.index ["event_id", "key"], name: "index_event_details_on_event_id_and_key", unique: true
    t.index ["event_id"], name: "index_event_details_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "bucket_id", null: false
    t.datetime "created_at", null: false
    t.bigint "eventable_id", null: false
    t.string "eventable_type", null: false
    t.bigint "person_id"
    t.bigint "subject_id", null: false
    t.bigint "subject_previous_id"
    t.string "subject_previous_type"
    t.string "subject_type", null: false
    t.index ["bucket_id"], name: "index_events_on_bucket_id"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
    t.index ["person_id"], name: "index_events_on_person_id"
    t.index ["subject_previous_type", "subject_previous_id"], name: "index_events_on_subject_previous"
    t.index ["subject_type", "subject_id"], name: "index_events_on_subject_type_and_subject_id"
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "recording_id", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_people_on_recording_id"
  end

  create_table "person_cards", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
  end

  create_table "publication_states", force: :cascade do |t|
    t.string "state", null: false
    t.index ["state"], name: "index_publication_states_on_state", unique: true
  end

  create_table "recordings", force: :cascade do |t|
    t.bigint "bucket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "parent_id"
    t.bigint "recordable_id", null: false
    t.string "recordable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["bucket_id"], name: "index_recordings_on_bucket_id"
    t.index ["discarded_at"], name: "index_recordings_on_discarded_at"
    t.index ["parent_id"], name: "index_recordings_on_parent_id"
    t.index ["recordable_type", "recordable_id"], name: "index_recordings_on_recordable_type_and_recordable_id"
  end

  create_table "search_indices", force: :cascade do |t|
    t.text "content", null: false
    t.string "recordable_type", null: false
    t.bigint "recording_id", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, content)", stored: true
    t.index ["recordable_type"], name: "index_search_indices_on_recordable_type"
    t.index ["recording_id"], name: "index_search_indices_on_recording_id", unique: true
    t.index ["searchable"], name: "index_search_indices_on_searchable", using: :gin
  end

  create_table "tag_states", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tag_states_on_tag_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  add_foreign_key "event_details", "events"
  add_foreign_key "events", "buckets"
  add_foreign_key "events", "people"
  add_foreign_key "people", "recordings"
  add_foreign_key "recordings", "buckets"
  add_foreign_key "recordings", "recordings", column: "parent_id"
  add_foreign_key "search_indices", "recordings"
  add_foreign_key "tag_states", "tags"
end
