module User::ActivitiesHelper
  def gender_activity_view activity
    action = model_tracking activity.trackable_type
    action_text = action_type_tracking activity.key
    field_name = field_name_tracking activity
    date = activity.created_at.strftime(Settings.tracking.date_format)
    time = activity.created_at.strftime(Settings.tracking.time_format)
    user_name = activity.owner&.name

    content_tag(:div, class: "tracking-item") do
      gen_track_content date, time, action, user_name, action_text, field_name
    end
  end

  private

  def gen_track_content date, time, action, user_name, action_text, field_name
    concat content_tag(:div, "",
                       class: "tracking-icon status-outfordelivery")
    concat(content_tag(:div, class: "tracking-date") do
      concat date
      concat content_tag(:span, time)
    end)
    concat(content_tag(:div, class: "tracking-content") do
      concat content_tag(:div, action, class: "color-tracking-model")
      concat(content_tag(:span) do
        concat(user_name)
        concat " "
        concat content_tag(:strong, action_text, class: "color-tracking-action")
        concat " "
        concat content_tag(:strong, field_name)
      end)
    end)
  end

  def model_tracking model
    case model.to_sym
    when :BookingField
      I18n.t("user.activities.helper.model.booking_field")
    when :Favorite
      I18n.t("user.activities.helper.model.favorite")
    else
      I18n.t("user.activities.helper.model.activity")
    end
  end

  def action_type_tracking type
    case type
    when "booking_field.create"
      I18n.t("user.activities.helper.action_type.booked")
    when "booking_field.canceled"
      I18n.t("user.activities.helper.action_type.canceled")
    when "booking_field.paid"
      I18n.t("user.activities.helper.action_type.paid")
    when "favorite.create"
      I18n.t("user.activities.helper.action_type.favorite")
    when "favorite.destroy"
      I18n.t("user.activities.helper.action_type.unfavorite")
    else
      I18n.t("user.activities.helper.action_type.perform_action")
    end
  end

  def field_name_tracking activity
    if activity.trackable_type.to_sym == :Favorite
      favoritable = activity.trackable&.favoritable
      if favoritable.is_a?(Field)
        favoritable.name
      else
        I18n.t("user.activities.helper.model_name.field")
      end
    else
      activity.trackable.try(:field).try(:name) ||
        I18n.t("user.activities.helper.model_name.field")
    end
  end
end
