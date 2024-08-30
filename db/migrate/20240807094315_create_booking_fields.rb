class CreateBookingFields < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_fields do |t|
      t.references :user, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true
      t.date :date, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.float :total
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
