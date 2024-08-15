class RemoveUsedAtFromUseVouchers < ActiveRecord::Migration[7.0]
  def change
    remove_column :use_vouchers, :used_at, :datetime
  end
end
