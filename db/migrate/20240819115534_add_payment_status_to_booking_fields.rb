class AddPaymentStatusToBookingFields < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_fields, :paymentStatus, :integer, default: 1
  end
end
