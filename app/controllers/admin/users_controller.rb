class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: %i(destroy)

  def index
    @q = User.ransack(params[:q].try(:merge, m: "or"),
                      auth_object: set_ransack_auth_object)
    @users = @q.result(distinct: true)
    @pagy, @users = pagy @users,
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

  def set_ransack_auth_object
    current_user.admin? ? :admin : nil
  end

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".messages.error_user_not_found"
    redirect_to admin_users_path
  end
end
