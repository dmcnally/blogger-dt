class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :eventable_type, null: false
      t.bigint :eventable_id, null: false
      t.string :recordable_type, null: false
      t.bigint :recordable_id, null: false
      t.string :recordable_previous_type
      t.bigint :recordable_previous_id
      t.string :action, null: false
      t.bigint :person_id
      t.datetime :created_at, null: false
    end

    add_index :events, [:eventable_type, :eventable_id]
    add_index :events, [:recordable_type, :recordable_id]
    add_index :events, [:recordable_previous_type, :recordable_previous_id],
              name: "index_events_on_recordable_previous"
  end
end
