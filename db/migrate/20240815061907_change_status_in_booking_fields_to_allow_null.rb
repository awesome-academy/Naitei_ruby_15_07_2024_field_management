class ChangeStatusInBookingFieldsToAllowNull < ActiveRecord::Migration[7.0]
  def change
    change_column :booking_fields, :status, :integer, null: true
  end
end
