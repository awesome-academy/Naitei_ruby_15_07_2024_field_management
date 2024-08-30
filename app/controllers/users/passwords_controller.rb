class Users::PasswordsController < Devise::PasswordsController
  def create
    super do |resource|
      if successfully_sent? resource
        flash[:info] = I18n.t("devise.passwords.instruction")
      end
    end
  end
end
