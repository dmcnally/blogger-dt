class CreateBuckets < ActiveRecord::Migration[8.1]
  def change
    create_table :buckets do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
