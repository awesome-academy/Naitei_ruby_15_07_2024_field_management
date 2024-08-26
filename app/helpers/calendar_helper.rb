module CalendarHelper
  def render_calendar field, date, path
    @field = field
    @date = date
    @path = path
    @start_of_week = @date.beginning_of_week
    @end_of_week = @date.end_of_week
    @bookings = fetch_bookings(@start_of_week, @end_of_week)
    @time_slots = generate_time_slots

    render partial: "shared/calendar", locals: {path:}
  end

  private

  def fetch_bookings start_of_week, end_of_week
    @field.booking_fields
          .by_date_range(start_of_week, end_of_week)
          .excluding_status("canceled")
          .to_a
  end

  def generate_time_slots
    start_time = Time.zone.parse(Settings.calendar.start_time)
    end_time = Time.zone.parse(Settings.calendar.end_time)
    interval = Settings.calendar.interval.minutes
    slots = []
    current_time = start_time
    while current_time <= end_time
      slots << current_time
      current_time += interval
    end
    slots
  end

  def days_row
    content_tag :div, class: "days-row" do
      concat content_tag(:div, Settings.calendar.GMT, class: "day-cell")
      (@start_of_week..@end_of_week).each do |day|
        concat day_cell day
      end
    end
  end

  def day_cell day
    content_tag :div, class: "day-cell #{'today' if day == Time.zone.today}" do
      concat content_tag(:div, day.strftime("%d"), class: "day-number")
      concat content_tag(:div,
                         I18n.t("calendar.days.#{day.strftime('%A').downcase}"),
                         class: "day-name")
    end
  end

  def time_slot_row time
    content_tag :div, class: "time-slot-row" do
      concat content_tag(:div,
                         time.strftime(Settings.calendar.time_format),
                         class: "time-slot")
      (@start_of_week..@end_of_week).each do |day|
        concat day_slot day, time
      end
    end
  end

  def bookings_for_day_at_time day, time
    @bookings.select do |booking|
      booking.status != "canceled" &&
        booking.date == day &&
        booking.start_time.strftime(Settings.calendar.time_format) <=
          time.strftime(Settings.calendar.time_format) &&
        booking.end_time.strftime(Settings.calendar.time_format) >
          time.strftime(Settings.calendar.time_format)
    end
  end

  def outside_operating_hours? time
    open_time = @field.open_time.strftime(Settings.calendar.time_format)
    close_time = @field.close_time.strftime(Settings.calendar.time_format)
    time.strftime(Settings.calendar.time_format) < open_time ||
      time.strftime(Settings.calendar.time_format) > close_time
  end

  def day_slot day, time
    bookings = bookings_for_day_at_time day, time

    css_classes = bookings.map do |booking|
      "booked-#{booking.pending? ? 0 : 1}"
    end.join(" ")

    if outside_operating_hours?(time) && css_classes.empty?
      css_classes = "booked-3"
    end

    content_tag :div, class: "day-slot #{css_classes}" do
      bookings.each do |booking|
        concat content_tag(:div, booking.user.name) if current_user&.admin?
      end
    end
  end

  def current_time_indicator
    content_tag :div, "", id: "current-time-indicator",
                  class: "current-time-indicator"
  end

  def month_year_format date
    month = I18n.t("calendar.months.#{date.strftime('%B').downcase}")
    year = date.strftime(", %Y")
    "#{month}#{year}"
  end
end
