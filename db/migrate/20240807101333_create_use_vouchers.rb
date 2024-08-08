class CreateUseVouchers < ActiveRecord::Migration[7.0]
  def change
    create_table :use_vouchers do |t|
      t.references :voucher, null: false, foreign_key: true
      t.datetime :used_at, null: false
      t.references :booking_field, null: false, foreign_key: true
     
      t.timestamps
    end
  end
end
