class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      reset_session
      log_in user
      redirect_to fields_path, status: :see_other
    else
      flash.now[:danger] = t ".messages.invalid_params_sign_in"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
