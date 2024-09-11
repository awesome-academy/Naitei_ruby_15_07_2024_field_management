class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    user = User.from_omniauth(from_google_params)

    if user.present?
      sign_out_all_scopes
      flash[:notice] = t "devise.omniauth_callbacks.success", kind: "Google"
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] =
        t "devise.omniauth_callbacks.failure", kind: "Google",
reason: "#{auth.info.email} is not authorized."
      redirect_to root_path
    end
  end

  def from_google_params
    request.env["omniauth.auth"]
  end

  def auth
    @auth ||= request.env["omniauth.auth"]
  end
end
