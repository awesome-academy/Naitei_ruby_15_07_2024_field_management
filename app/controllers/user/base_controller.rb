class User::BaseController < ApplicationController
  before_action :require_user

  private

  def require_user
    return if current_user

    flash[:alert] = t "user.base.not_user"
    redirect_to signin_path
  end
end
