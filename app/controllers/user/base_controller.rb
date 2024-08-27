class User::BaseController < ApplicationController
  load_and_authorize_resource

  private

  def require_user
    return if current_user

    flash[:alert] = t "user.base.not_user"
    redirect_to signin_path
  end
end
