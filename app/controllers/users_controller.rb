class UsersController < ApplicationController
  before_action :set_user, only: %i(show)

  def show; end

  private

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".messages.error_user_not_found"
    redirect_to admin_users_path
  end
end
