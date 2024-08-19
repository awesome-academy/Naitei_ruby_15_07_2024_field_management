class User::BookingFieldsController < ApplicationController
  before_action :logged_in, :login_as_user, only: %i(new create)
  before_action :get_booking_field, only: %i(pay demo_payment)
  def new
    @field = Field.find_by id: params[:field_id]
    if @field.nil?
      flash[:danger] = t ".field_not_found"
      redirect_to fields_path
    else
      @booking_field = BookingField.new
    end
  end

  def create
    @booking_field = current_user.booking_fields.build booking_params

    if @booking_field.save
      @booking_field.update_column(:status, :pending)
      redirect_to pay_user_booking_field_path(@booking_field)
    else
      @field = Field.find_by id: params[:booking_field][:field_id]
      @booking_field.assign_attributes(@booking_field.attributes
                                          .transform_values{nil})
      render :new
    end
  end

  def pay
    render :show_pay
  end

  def demo_payment
    flash[:success] = t ".booking_success"
    @booking_field.update_column(:status, :approval)
    redirect_to root_path
  end

  private

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
end
