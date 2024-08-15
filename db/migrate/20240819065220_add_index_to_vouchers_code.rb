class AddIndexToVouchersCode < ActiveRecord::Migration[7.0]
  def change
    add_index :vouchers, :code, unique: true
  end
end
