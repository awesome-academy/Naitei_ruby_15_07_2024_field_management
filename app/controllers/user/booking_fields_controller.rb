class User::BookingFieldsController < User::BaseController
  skip_load_and_authorize_resource only: :create
  before_action :logged_in, :login_as_user,
                only: %i(new create pay demo_payment export)
  before_action :get_booking_field, only: %i(pay demo_payment update)
  before_action :set_field_and_date, only: :new

  def index
    @q = current_user.booking_fields.ransack(params[:q])
    @booking_fields = @q.result.includes(:field)
    @pagy, @booking_fields = pagy @booking_fields,
                                  limit: Settings.user.booking_fields_pagy
  end

  def update
    process_canceled
    process_paid
  end

  def new
    if @field.nil?
      flash[:danger] = t ".field_not_found"
      redirect_to fields_path
    else
      @booking_field = BookingField.new
      @vouchers = Voucher.available_vouchers
    end
  end

  def create
    authorize! :create, BookingField
    @booking_field = current_user.booking_fields.build booking_params
    process_vouchers

    if @booking_field.check_vouchers(@vouchers) && @booking_field.save
      handle_success_save_booking
    else
      handle_fail_save_booking
    end
  end

  def pay
    authorize! :pay, BookingField
    render :show_pay
  end

  def demo_payment
    authorize! :demo_payment, BookingField
    @booking_field.approval!
    @booking_field.paid!
    flash[:success] = t ".booking_success"
    redirect_to root_path
  end

  def export
    @q = current_user.booking_fields.ransack(params[:q])
    @bookings_export = @q.result(distance: true).includes(:field)
    respond_to do |format|
      format.json do
        @job_id = ExportBookingJob.perform_async(@bookings_export.as_json(
                                                   include: [:field]
                                                 ))
        render json: {
          jid: @job_id
        }
      end
    end
  end

  def export_status
    respond_to do |format|
      format.json do
        job_id = params[:job_id]
        job_status = Sidekiq::Status.get_all(job_id).symbolize_keys
        percent = Sidekiq::Status.pct_complete job_id
        render json: {
          status: job_status[:status],
          percentage: percent
        }
      end
    end
  end

  def export_download
    job_id = params[:job_id]

    respond_to do |format|
      format.xlsx do
        send_file Rails.root.join("public", "data", "bookings_#{job_id}.xlsx")
      end
    end
  end

  private

  def handle_success_save_booking
    redirect_to pay_user_booking_field_path @booking_field
  end

  def handle_fail_save_booking
    @field = Field.find_by id: params[:booking_field][:field_id]
    @booking_field.assign_attributes(@booking_field.attributes
                                        .transform_values{nil})
    @vouchers = Voucher.available_vouchers
    @date = Time.zone.today
    render :new
  end

  def process_canceled
    return if params[:canceled].blank?

    @booking_field.canceled!
    BookingFieldMailer.status_change_notification(@booking_field).deliver_now
    flash[:success] = t ".cancel_booking_successfully"
    redirect_to user_history_path
  end

  def process_paid
    return if params[:paid].blank?

    redirect_to pay_user_booking_field_path @booking_field
  end

  def process_vouchers
    return if params[:voucher_ids].nil?

    @vouchers = Voucher.find_with_list_ids params[:voucher_ids]
    @booking_field.vouchers = @vouchers
  end

  def get_booking_field
    @booking_field = BookingField.find_by id: params[:id]
    return unless @booking_field.nil?

    flash[:danger] = t ".booking_field_not_found"
    redirect_to fields_path
  end

  def booking_params
    params.require(:booking_field).permit BookingField::BOOKING_PARAMS
  end

  def logged_in
    return if logged_in?

    store_location
    flash[:danger] = t ".please_log_in"
    redirect_to signin_url
  end

  def login_as_user
    return if current_user.user?

    flash[:danger] = t ".you_are_not_user"
    redirect_to root_path
  end

  def set_field_and_date
    @field = Field.find_by id: params[:field_id]
    @date = if params[:date].presence
              Date.parse(params[:date].to_s)
            else
              Time.zone.today
            end
  end
end
