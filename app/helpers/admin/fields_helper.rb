module Admin::FieldsHelper
  def render_field_status_calendar field, selected_date
    render_calendar(
      field,
      selected_date,
      ->(f, d){status_admin_field_path(f, date: d)}
    )
  end

  def render_existing_images_script existing_images
    return unless existing_images.any?

    content_tag :script do
      "var existingImages = #{existing_images.to_json};".html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
