module Admin::UsersHelper
  def gravatar_for user, options = {size: Settings.users.avatar_size_50}
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def user_activation_status user
    if user.activated
      content_tag :span, I18n.t("admin.users.activate.activated"),
                  class: "user-activated"
    else
      content_tag :span, I18n.t("admin.users.activate.not_activated"),
                  class: "user-not-activated"
    end
  end

  def user_actions user
    view_button = link_to(I18n.t("admin.users.button.view"), user_path(user),
                          class: "btn btn-info btn-sm")

    unless user.admin?
      delete_button = link_to(
        I18n.t("admin.users.button.delete"),
        admin_user_path(user),
        data: {turbo_method: :delete,
               turbo_confirm: I18n.t("admin.users.button.confirm_delete")},
        class: "btn btn-danger btn-sm"
      )
    end

    safe_join([view_button, delete_button].compact, " ")
  end
end
