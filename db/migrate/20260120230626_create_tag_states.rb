class CreateTagStates < ActiveRecord::Migration[8.1]
  def change
    create_table :tag_states do |t|
      t.references :tag, null: false, foreign_key: true, index: { unique: true }
      t.boolean :available, null: false, default: true
      t.timestamps
    end
  end
end
