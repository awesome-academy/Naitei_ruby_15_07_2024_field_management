class CreateVouchers < ActiveRecord::Migration[7.0]
  def change
    create_table :vouchers do |t|
      t.string :code, null: false, unique: true
      t.string :name, null: false
      t.float :value, null: false
      t.date :expired_date, null: false
      t.integer :status, null: false, default: 0
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
