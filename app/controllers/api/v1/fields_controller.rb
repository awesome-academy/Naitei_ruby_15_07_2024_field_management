class Api::V1::FieldsController < ApplicationController
  protect_from_forgery with: :null_session

  include Authenticable

  skip_before_action :authenticate_user!, only: %i(index average_rating show)
  before_action :authenticate_admin!, only: %i(create update destroy status)
  before_action :set_field, only: %i(destroy update average_rating show status)

  def show
    images = @field.images.map do |image|
      {
        id: image.id,
        url: rails_blob_url(image, only_path: true)
      }
    end

    bookings = @field.booking_fields.map do |booking|
      {
        id: booking.id,
        date: booking.date,
        start_time: booking.start_time,
        end_time: booking.end_time,
        status: booking.status
      }
    end

    render json: {
      field: @field.as_json.merge(images:, bookings:),
      average_rating: avg_rating
    }, status: :ok
  end

  def status
    bookings = @field.booking_fields.map do |booking|
      {
        id: booking.id,
        user_id: booking.user_id,
        date: booking.date,
        start_time: booking.start_time,
        end_time: booking.end_time,
        status: booking.status,
        field_id: booking.field_id,
        total: booking.total,
        paymentStatus: booking.paymentStatus
      }
    end

    render json: {
      field: @field.as_json.merge(bookings:),
      average_rating: avg_rating
    }, status: :ok
  end

  def index
    @q = Field.ransack params[:q]
    @fields = @q.result(distinct: true).with_ave_rate

    render json: @fields, each_serializer: FieldSerializer,
           current_user: @current_user, status: :ok
  end

  def create
    @field = Field.new field_params

    if @field.save
      attach_images if params[:images].present?
      render json: @field, serializer: FieldSerializer, status: :created
    else
      render json: {errors: @field.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def destroy
    unless can_destroy_field?
      render json: {message: I18n.t("api.v1.field.delete.unauthorized")},
             status: :ok
      return
    end

    if @field.destroy
      render json: {message: I18n.t("api.v1.field.delete.success")}, status: :ok
    else
      render json: {error: I18n.t("api.v1.field.delete.failure")},
             status: :unprocessable_entity
    end
  end

  def update
    if @field.update field_params
      replace_images if params[:field][:images].present?
      render json: @field, serializer: FieldSerializer, status: :ok
    else
      render json: {errors: @field.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def average_rating
    render json: {average_rating: avg_rating}, status: :ok
  end

  private

  def set_field
    @field = Field.find params[:id]
  rescue ActiveRecord::RecordNotFound
    render json: {error: I18n.t("api.v1.field.not_found")}, status: :not_found
  end

  def can_destroy_field?
    @field.booking_fields
          .future_bookings
          .pending_or_approved
          .none?
  end

  def field_params
    params.require(:field).permit(Field::PERMITTED_ATTRIBUTES + [images: []])
  end

  def attach_images
    return if params[:field][:images].blank?

    params[:field][:images].each do |image|
      @field.images.attach image
    end
  end

  def replace_images
    @field.images.purge

    params[:field][:images].each do |image|
      @field.images.attach image
    end
  end

  def avg_rating
    avg_rating = @field.ratings.average(:rating).to_f
    avg_rating.nan? ? 0 : avg_rating
  end
end
