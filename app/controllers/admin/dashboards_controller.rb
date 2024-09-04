class Admin::DashboardsController < ApplicationController
  before_action :find_field, only: %i(show)
  before_action :find_params_statistic
  def index
    @q = BookingField.ransack(params[:q])
    @filtered_bookings = @q.result.includes(:field)

    return unless validate_date_range

    @revenue_data = @filtered_bookings
                    .grouped_revenue(@analysis_type,
                                     @date_from, @date_to)

    @revenue_by_capacity = @filtered_bookings.revenue_by_capacity
    @revenue_by_grass = @filtered_bookings.revenue_by_grass
  end

  def show
    @q = @field.booking_fields.ransack(params[:q])
    @booking_fields = @q.result(distinct: true)
    return unless validate_date_range

    @revenue_field_data = @booking_fields
                          .grouped_revenue(@analysis_type,
                                           @date_from, @date_to)
  end

  private

  def find_field
    @field = Field.find_by id: params[:id]
    return if @field.present?

    flash[:danger] = t "admin.fields.messages.error_field_not_found"
    redirect_to fields_path
  end

  def find_params_statistic
    @date_from = find_date_from
    @date_to = find_date_to
    @analysis_type = find_analysis_type
  end

  def find_date_from
    if params.dig(:q, :date_gteq).present?
      Date.parse(params[:q][:date_gteq])
    else
      Settings.chartkick.date_from_default.month.ago.to_date
    end
  end

  def find_date_to
    if params.dig(:q,
                  :date_lteq).present?
      Date.parse(params.dig(:q, :date_lteq))
    else
      Time.zone.today
    end
  end

  def find_analysis_type
    params[:analysis_type].presence || :month
  end

  def validate_date_range
    return true unless @date_to < @date_from

    flash[:danger] = t "admin.dashboards.validate_date"
    false
  end
end
