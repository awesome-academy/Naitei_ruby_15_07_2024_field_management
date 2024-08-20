class SessionsController < ApplicationController
  def new; end

  def create
    user = find_user_by_email
    if user&.authenticate params[:session][:password]
      check_activation_status user
    else
      handle_failed_login
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def find_user_by_email
    User.find_by email: params[:session][:email].downcase
  end

  def check_activation_status user
    if user.activated?
      handle_successful_login user
    else
      flash[:danger] = t ".messages.account_not_activated"
      redirect_to root_url
    end
  end

  def handle_successful_login user
    reset_session
    log_in user
    redirect_user user
  end

  def handle_failed_login
    flash.now[:danger] = t ".messages.invalid_params_sign_in"
    render :new, status: :unprocessable_entity
  end

  def redirect_user user
    if user.admin?
      redirect_to admin_booking_fields_path, status: :see_other
    else
      redirect_to fields_path, status: :see_other
    end
  end
end
