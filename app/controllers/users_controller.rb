class UsersController < ApplicationController
  before_action :set_user, only: %i(show)

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = t ".messages.check_mail"
      redirect_to root_url, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".messages.error_user_not_found"
    redirect_to admin_users_path
  end

  def user_params
    params.require(:user).permit User::PERMITTED_ATTRIBUTES
  end
end
