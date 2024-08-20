module User::BookingFieldsHelper
  def user_render_field_status_calendar field, selected_date
    render_calendar(
      field,
      selected_date,
      ->(f, d){new_user_booking_field_path(field_id: f.id, date: {date: d})}
    )
  end

  def select_status_booking
    select_status(:statuses, :status)
  end

  def select_payment_status_booking
    select_status(:paymentStatuses, :paymentStatus)
  end

  def select_status option_type, param_key
    options_for_select(
      BookingField.public_send(option_type).keys.map do |status|
        [status.capitalize, status]
      end, params[param_key]
    )
  end
end
