class ExportBookingJob
  include Sidekiq::Job
  include Sidekiq::Status::Worker
  require "caxlsx"

  def perform bookings_export
    total bookings_export.size

    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Bookings History") do |sheet|
      generate_excel_file(sheet, bookings_export, wb)
    end
    p.serialize Rails.root.join("public", "data", "bookings_#{jid}.xlsx")
  end

  private

  def generate_excel_file sheet, booking_fields, workbook
    gen_header sheet, workbook
    gen_content sheet, booking_fields
  end

  def gen_header sheet, workbook
    sheet.add_row [
      I18n.t("job.export.field_name"),
      I18n.t("job.export.date"),
      I18n.t("job.export.start_time"),
      I18n.t("job.export.end_time"),
      I18n.t("job.export.total_price"),
      I18n.t("job.export.status"),
      I18n.t("job.export.payment_status")
    ], style: header_style(workbook)
  end

  def gen_content sheet, booking_fields
    booking_fields.each do |b|
      booking = BookingField.find_by id: b["id"]
      sheet.add_row [
        booking.field.name,
        booking.date,
        format_time(booking.start_time),
        format_time(booking.end_time),
        booking.total,
        booking.status,
        booking.paymentStatus
      ]
    end
  end

  def header_style workbook
    workbook.styles.add_style(
      b: true,
      border: {style: :thin, color: "333"},
      alignment: {horizontal: :center}
    )
  end

  def content_style workbook
    workbook.styles.add_style(
      border: {style: :thin, color: "333"},
      alignment: {horizontal: :center}
    )
  end

  def format_time time
    time.strftime(Settings.calendar.time_format)
  end
end
