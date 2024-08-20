class Admin::BookingFieldsController < Admin::BaseController
  def index
    @pagy, @booking_fields = pagy BookingField.filtered(params),
                                  limit: Settings.admin.booking_fields_pagy
  end

  def update
    @booking_field = BookingField.find_by id: params[:id]
    respond_to do |format|
      success_message = t ".messages.success_change_status"
      error_message = t ".messages.error_change_status"

      if @booking_field.update(booking_field_params)
        BookingFieldMailer.status_change_notification(@booking_field)
                          .deliver_now
        flash[:success] = success_message
      else
        flash[:danger] = error_message
      end

      format.turbo_stream
      format.html{redirect_to admin_booking_fields_path}
    end
  end

  private

  def booking_field_params
    params.require(:booking_field).permit :status
  end
end
