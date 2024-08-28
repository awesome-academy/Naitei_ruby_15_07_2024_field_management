class User::UsersController < User::BaseController
  before_action :load_user
  before_action :correct_user, only: %i(edit update)
  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".message.updated"
      redirect_to @user
    else
      flash[:danger] = t ".message.save_fail"
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".message.not_found"
    redirect_to root_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t ".message.not_correct_user"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit User::PERMITTED_ATTRIBUTES
  end
end
