module FieldsHelper
  def display_rating rating
    full_stars = rating.to_i
    half_star = (rating - full_stars) >= 0.5 ? 1 : 0
    empty_stars = 5 - full_stars - half_star

    content_tag :span, class: "rating-star" do
      (full_stars.times.map{content_tag(:i, "", class: "fa fa-star")} +
      (if half_star.positive?
         [content_tag(:i, "",
                      class: "fa fa-star-half")]
       else
         []
       end) +
      empty_stars.times.map do
        content_tag(:i, "", class: "fa fa-star empty-star")
      end).join.html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  def field_link field
    if current_user&.admin?
      status_admin_field_path field
    else
      field_path field
    end
  end

  def render_create_field_button
    return unless current_user&.admin?

    link_to I18n.t("fields.create.create_field_button"), new_admin_field_path,
            class: "btn btn-success"
  end

  def render_favorite_button_if_user field
    return unless current_user&.user?

    content_tag :div, id: "favorite_button_#{field.id}" do
      render "favorite_button", field:
    end
  end
end
