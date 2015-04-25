class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.integer :emergency_id
      t.string :name
      t.string :type
      t.integer :capacity
      t.boolean :on_duty, default: false
      t.timestamps null: false
    end
  end
end
