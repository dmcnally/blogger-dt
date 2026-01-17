class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      # No t.timestamps - event tracking handles this
    end
  end
end
