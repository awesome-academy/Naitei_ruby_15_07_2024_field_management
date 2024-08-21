class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t(".subject_mail")
  end
end
