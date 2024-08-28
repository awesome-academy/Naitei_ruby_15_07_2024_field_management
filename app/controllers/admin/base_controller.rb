class Admin::BaseController < ApplicationController
  load_and_authorize_resource

  private

  def require_admin
    return if current_user&.admin?

    flash[:alert] = t "admin.base.not_admin"
    redirect_to(root_path)
  end
end
