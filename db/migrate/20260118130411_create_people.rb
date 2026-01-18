class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :person_cards do |t|
      t.string :first_name
      t.string :last_name
      # No timestamps - event tracking handles this
    end

    create_table :people do |t|
      t.references :recording, null: false, foreign_key: true
      t.timestamps
    end

    add_index :events, :person_id
    add_foreign_key :events, :people
  end
end
