class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.integer :emergency_id
      t.string :name
      t.string :type
      t.integer :capacity
      t.boolean :on_duty
      t.timestamps null: false
    end
  end
end
