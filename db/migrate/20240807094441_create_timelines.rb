class CreateTimelines < ActiveRecord::Migration[7.0]
  def change
    create_table :timelines do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :date, null: false

      t.timestamps
    end
  end
end
