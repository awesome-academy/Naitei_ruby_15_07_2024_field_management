class CheckPaymentJob < ApplicationJob
  queue_as :default

  def perform booking_field_id
    booking_field = BookingField.find_by id: booking_field_id
    if booking_field.nil?
      message = I18n.t("job.check_payment_status.not_found",
                       id: booking_field_id)
      Rails.logger.info message
    else
      return unless booking_field.unpaid? && booking_field.pending?

      booking_field.update_column(:status, :canceled)
    end
  end
end
