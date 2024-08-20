class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i(destroy)

  def index
    @pagy, @users = pagy User.search_by_name(params[:name]),
                         limit: Settings.users.pagy_10
  end

  def destroy
    if @user.admin?
      flash[:danger] = t ".cannot_delete"
    else
      @user.destroy
      flash[:success] = t ".success_message"
    end
    redirect_to admin_users_path
  end

  private

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".messages.error_user_not_found"
    redirect_to admin_users_path
  end
end
