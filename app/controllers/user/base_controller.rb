class User::BaseController < ApplicationController
  load_and_authorize_resource

  def store_user_location
    store_location_for(:user, request.fullpath)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? &&
      !user_signed_in?
  end

  private

  def require_user
    return if current_user

    flash[:alert] = t "user.base.not_user"
    redirect_to signin_path
  end
end
