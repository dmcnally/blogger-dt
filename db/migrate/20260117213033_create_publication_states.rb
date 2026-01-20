class CreatePublicationStates < ActiveRecord::Migration[8.1]
  def change
    create_table :publication_states do |t|
      t.string :state, null: false
    end

    add_index :publication_states, :state, unique: true
  end
end
