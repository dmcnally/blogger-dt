class CreateRecordings < ActiveRecord::Migration[8.1]
  def change
    create_table :recordings do |t|
      t.references :parent, foreign_key: { to_table: :recordings }
      t.string :recordable_type, null: false
      t.bigint :recordable_id, null: false
      t.timestamps
    end

    add_index :recordings, [ :recordable_type, :recordable_id ]
  end
end
