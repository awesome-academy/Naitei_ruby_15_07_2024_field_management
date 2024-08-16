class Admin::FieldsController < Admin::BaseController
  before_action :set_field_and_date, only: [:status]

  def status
    if @field
      # Process
    else
      flash[:danger] = t ".messages.error_field_not_found"
      redirect_to fields_path
    end
  end

  private

  def set_field_and_date
    @field = Field.find_by(id: params[:id])
    @date = if params[:date].present?
              Date.parse(params[:date].to_s)
            else
              Time.zone.today
            end
  end
end
