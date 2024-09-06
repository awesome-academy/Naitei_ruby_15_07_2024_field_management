class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: %i(create)
  skip_before_action :require_no_authentication, only: %i(create)

  def create
    sign_out current_user if current_user

    super do |user|
      if user
        if request.content_type == "application/json"
          token = JwtService.encode(
            user_id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
          )
          render json: {token:}, status: :ok and return
        end

        redirect_to root_path and return
      end
    end
  end
end
