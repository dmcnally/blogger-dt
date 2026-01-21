class CreateCounterCaches < ActiveRecord::Migration[8.1]
  def change
    create_table :counter_caches do |t|
      t.references :counterable, polymorphic: true, null: false
      t.string :name, null: false
      t.integer :count, null: false, default: 0
    end
    add_index :counter_caches,
              [ :counterable_type, :counterable_id, :name ],
              unique: true,
              name: "index_counter_caches_uniqueness"
  end
end
