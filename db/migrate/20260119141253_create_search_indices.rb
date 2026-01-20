class CreateSearchIndices < ActiveRecord::Migration[8.1]
  def change
    create_table :search_indices do |t|
      t.references :recording, null: false, foreign_key: true, index: { unique: true }
      t.string :recordable_type, null: false
      t.text :content, null: false
      t.virtual :searchable, type: :tsvector, as: "to_tsvector('english', content)", stored: true
    end

    add_index :search_indices, :searchable, using: :gin
    add_index :search_indices, :recordable_type
  end
end
