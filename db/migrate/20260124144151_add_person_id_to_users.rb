class AddPersonIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :person, null: false, foreign_key: true
  end
end
