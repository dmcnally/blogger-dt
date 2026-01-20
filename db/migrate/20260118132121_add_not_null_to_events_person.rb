class AddNotNullToEventsPerson < ActiveRecord::Migration[8.1]
  def change
    change_column_null :events, :person_id, false
  end
end
