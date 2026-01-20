class CreateEventDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :event_details do |t|
      t.references :event, null: false, foreign_key: true
      t.string :key, null: false
      t.text :value
    end

    add_index :event_details, [:event_id, :key], unique: true
  end
end
