class CreateFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.float :price, null: false
      t.integer :grass, default: 0
      t.integer :capacity, default: 7
      t.datetime :open_time
      t.datetime :close_time
      t.integer :block_time, default: 1

      t.timestamps
    end
  end
end
