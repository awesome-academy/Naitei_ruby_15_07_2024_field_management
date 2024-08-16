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
      attach_images if params[:field][:image_storage].present?
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

  def attach_images
    image_data = JSON.parse params[:field][:image_storage]
    image_data.each do |base64_image|
      decoded_image = Base64.decode64 base64_image.split(",").last
      filename = "field_image_#{SecureRandom.hex}.png"
      tempfile = Tempfile.new filename
      tempfile.binmode
      tempfile.write decoded_image
      tempfile.rewind

      @field.images.attach(io: tempfile, filename:)
      tempfile.close
      tempfile.unlink
    end
  end
end
