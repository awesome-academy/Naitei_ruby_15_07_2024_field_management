class AddCancellationReasonToBookingFields < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_fields, :cancellation_reason, :text
  end
end
