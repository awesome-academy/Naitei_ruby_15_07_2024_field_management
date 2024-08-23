class AddUsedWithOtherToVouchers < ActiveRecord::Migration[7.0]
  def change
    add_column :vouchers, :used_with_other, :boolean, default: false
  end
end
