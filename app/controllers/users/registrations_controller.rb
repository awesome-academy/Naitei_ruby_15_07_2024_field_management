class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    super do |user|
      if user.persisted? && user.confirmed?
        flash[:success] = I18n.t("devise.registrations.signed_up")
      else
        flash[:info] = I18n.t("devise.registrations.signed_up_but_unconfirmed")
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: User::PERMITTED_ATTRIBUTES)
  end

  def after_sign_up_path_for resource
    if resource.confirmed?
      super resource
    else
      flash[:info] = I18n.t("devise.registrations.signed_up_but_unconfirmed")
      root_path
    end
  end
end
