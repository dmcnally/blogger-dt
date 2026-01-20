class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :eventable_type, null: false
      t.bigint :eventable_id, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
      t.string :subject_previous_type
      t.bigint :subject_previous_id
      t.string :action, null: false
      t.bigint :person_id
      t.datetime :created_at, null: false
    end

    add_index :events, [:eventable_type, :eventable_id]
    add_index :events, [:subject_type, :subject_id]
    add_index :events, [:subject_previous_type, :subject_previous_id],
              name: "index_events_on_subject_previous"
  end
end
