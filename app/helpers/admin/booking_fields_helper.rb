module Admin::BookingFieldsHelper
  def bootstrap_status_class status
    case status.to_sym
    when :pending
      "status-pending"
    when :approval
      "status-approval"
    when :canceled
      "status-canceled"
    else
      "status-default"
    end
  end

  def bootstrap_pay_status_class status
    case status.to_sym
    when :paid
      "status-pending"
    when :unpaid
      "status-canceled"
    else
      "status-default"
    end
  end

  def booking_fields_rows booking_fields
    rows = booking_fields.map{|booking_field| booking_field_row(booking_field)}
    safe_join(rows)
  end

  private

  def booking_field_row booking_field
    content_tag :tr do
      concat formatted_date_cell booking_field
      concat formatted_start_time_cell booking_field
      concat formatted_end_time_cell booking_field
      concat field_name_cell booking_field
      concat user_name_cell booking_field
      concat total_cell booking_field
      concat status_badge_cell booking_field
      concat status_form_cell booking_field
    end
  end

  def formatted_date_cell booking_field
    content_tag(:td, formatted_date(booking_field.date))
  end

  def formatted_start_time_cell booking_field
    content_tag(:td, formatted_time(booking_field.start_time))
  end

  def formatted_end_time_cell booking_field
    content_tag(:td, formatted_time(booking_field.end_time))
  end

  def field_name_cell booking_field
    content_tag(:td, booking_field.field.name)
  end

  def user_name_cell booking_field
    content_tag(:td, booking_field.user.name)
  end

  def total_cell booking_field
    content_tag(:td, booking_field.total)
  end

  def status_badge_cell booking_field
    content_tag(:td, status_badge(booking_field), class: "text-center")
  end

  def status_form_cell booking_field
    content_tag(:td, status_form(booking_field), class: "text-center")
  end

  def formatted_date date
    date&.strftime(Settings.admin.date_format)
  end

  def formatted_time time
    time&.strftime(Settings.admin.time_format)
  end

  def status_badge booking_field
    status_text = I18n.t "admin.booking_fields.statuses.#{booking_field.status}"
    content_tag(:span, status_text,
                class: "badge #{bootstrap_status_class booking_field.status}")
  end

  def payment_status_badge booking_field
    status_text =
      I18n.t "admin.booking_fields.statuses.#{booking_field.paymentStatus}"
    content_tag(:span, status_text,
                class: "badge
                  #{bootstrap_pay_status_class booking_field.paymentStatus}")
  end

  def status_form booking_field
    form_with model: [:admin, booking_field], method: :patch, local: true do |f|
      f.select :status,
               BookingField.statuses.keys.map {|status|
                 [I18n.t("admin.booking_fields.statuses.#{status}"), status]
               },
               {selected: booking_field.status},
               {class: "form-select", onchange: "this.form.submit()"}
    end
  end
end
