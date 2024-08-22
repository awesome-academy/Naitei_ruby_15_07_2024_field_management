module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    reset_session
    @current_user = nil
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def current_user? user
    user == current_user
  end
end
