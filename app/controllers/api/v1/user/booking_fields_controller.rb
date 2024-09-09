class Api::V1::User::BookingFieldsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :set_field_and_date, only: :new
  before_action :find_booking_field, :process_params, only: %i(update)
  def index
    @q = BookingField.ransack(params[:q])
    @booking_fields = @q.result.includes(:field)
    @pagy, @booking_fields = pagy @booking_fields,
                                  limit: Settings.user.booking_fields_pagy
    render json: @booking_fields, status: :ok
  end

  def new
    if @field.nil?
      render json: {
               message: I18n.t("api.v1.user.booking_fields.field_not_found")
             },
             status: :not_found
    else
      @booking_field = BookingField.new
      @vouchers = Voucher.available_vouchers
      render json: {
        booking_field: BookingFieldSerializer.new(@booking_field),
        vouchers: @vouchers.map{|voucher| VoucherSerializer.new(voucher)}
      }, status: :ok
    end
  end

  def update
    process_canceled
    process_paid
  end

  def create
    @booking_field = BookingField.new booking_params
    @booking_field.user = User.first
    process_vouchers

    if @booking_field.check_vouchers(@vouchers) && @booking_field.save
      handle_success_save_booking
    else
      handle_fail_save_booking
    end
  end

  private

  def handle_success_save_booking
    render json: {
      message: I18n.t("api.v1.user.booking_fields.success_create"),
      booking_field: BookingFieldSerializer.new(@booking_field)
    }, status: :created
  end

  def handle_fail_save_booking
    @field = Field.find_by id: params[:booking_field][:field_id]
    @booking_field.assign_attributes(@booking_field.attributes
                                        .transform_values{nil})
    @vouchers = Voucher.available_vouchers
    @date = Time.zone.today

    render json: {
      message: I18n.t("api.v1.user.booking_fields.fail_create"),
      booking_field: @booking_field.errors.full_messages
    }, status: :unprocessable_entity
  end

  def process_vouchers
    return if params[:voucher_ids].nil?

    @vouchers = Voucher.find_with_list_ids params[:voucher_ids]
    @booking_field.vouchers = @vouchers
  end

  def process_params
    return unless (params[:canceled].blank? && params[:paid].blank?) ||
                  params[:canceled].present? && params[:paid].present?

    render json: {
             message: I18n.t("api.v1.user.booking_fields.wrong_params")
           },
           status: :unprocessable_entity
  end

  def process_canceled
    return if params[:canceled].blank?

    if @booking_field.canceled!
      BookingFieldMailer.status_change_notification(@booking_field).deliver_now
      render json: {
        message: I18n.t("api.v1.user.booking_fields.cancel_success")
      }, status: :ok
    else
      render json: {
        message: I18n.t("api.v1.user.booking_fields.cancel_fail")
      }, status: :ok
    end
  end

  def process_paid
    return if params[:paid].blank?

    render json: {
      message: I18n.t("api.v1.user.booking_fields.link_to_pay")
    }, status: :ok
  end

  def booking_params
    params.require(:booking_field).permit BookingField::BOOKING_PARAMS
  end

  def find_booking_field
    @booking_field = BookingField.find_by id: params[:id]
    return unless @booking_field.nil?

    render json:
          {message: I18n.t("api.v1.user.booking_fields.booking_not_found")},
           status: :not_found
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
