class ChangeStartTimeAndEndTimeInBookingFields < ActiveRecord::Migration[7.0]
  def change
    change_column :booking_fields, :start_time, :time
    change_column :booking_fields, :end_time, :time
  end
end
