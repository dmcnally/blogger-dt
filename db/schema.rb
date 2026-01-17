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

ActiveRecord::Schema[8.1].define(version: 2026_01_17_183607) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.text "body"
    t.string "title", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
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
    t.datetime "created_at", null: false
    t.bigint "eventable_id", null: false
    t.string "eventable_type", null: false
    t.bigint "person_id"
    t.bigint "subject_id", null: false
    t.bigint "subject_previous_id"
    t.string "subject_previous_type"
    t.string "subject_type", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
    t.index ["subject_previous_type", "subject_previous_id"], name: "index_events_on_subject_previous"
    t.index ["subject_type", "subject_id"], name: "index_events_on_subject_type_and_subject_id"
  end

  create_table "recordings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "parent_id"
    t.bigint "recordable_id", null: false
    t.string "recordable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_recordings_on_parent_id"
    t.index ["recordable_type", "recordable_id"], name: "index_recordings_on_recordable_type_and_recordable_id"
  end

  add_foreign_key "event_details", "events"
  add_foreign_key "recordings", "recordings", column: "parent_id"
end
