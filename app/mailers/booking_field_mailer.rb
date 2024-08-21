class BookingFieldMailer < ApplicationMailer
  def status_change_notification booking_field
    @booking_field = booking_field
    @user = booking_field.user
    mail to: @user.email, subject: t("admin.booking_fields.mail.subject")
  end
end
