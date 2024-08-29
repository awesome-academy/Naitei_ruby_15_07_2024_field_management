class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url
    flash[:alert] = exception.message
  end

  protect_from_forgery with: :exception
  include Pagy::Backend
  include PublicActivity::StoreController

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
