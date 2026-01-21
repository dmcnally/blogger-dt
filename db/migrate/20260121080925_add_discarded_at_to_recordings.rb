class AddDiscardedAtToRecordings < ActiveRecord::Migration[8.1]
  def change
    add_column :recordings, :discarded_at, :datetime
    add_index :recordings, :discarded_at
  end
end
