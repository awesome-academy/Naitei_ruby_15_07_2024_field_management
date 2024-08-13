class AddAddressToFields < ActiveRecord::Migration[7.0]
  def change
    add_column :fields, :address, :string, default: "10 Thanh Xuan"
  end
end
