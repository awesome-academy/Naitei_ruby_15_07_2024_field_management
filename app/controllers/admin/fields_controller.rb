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

  def new
    @field = Field.new
  end

  def create
    @field = Field.new field_params

    if @field.save
      flash[:success] = t ".success_message"
      redirect_to new_admin_field_path, status: :see_other
    else
      flash.now[:danger] = t ".failure_message"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def field_params
    params.require(:field).permit(Field::PERMITTED_ATTRIBUTES)
  end

  def set_field_and_date
    @field = Field.find_by(id: params[:id])
    @date = if params[:date].present?
              Date.parse(params[:date].to_s)
            else
              Time.zone.today
            end
  end
end
