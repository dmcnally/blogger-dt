class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :person, null: false, foreign_key: true
      t.references :bucket, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :memberships, [ :person_id, :bucket_id ], unique: true
  end
end
