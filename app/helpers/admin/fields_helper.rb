module Admin::FieldsHelper
  def render_field_status_calendar field, selected_date
    render_calendar(
      field,
      selected_date,
      ->(f, d){status_admin_field_path(f, date: d)}
    )
  end
end
