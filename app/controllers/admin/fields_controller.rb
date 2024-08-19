class Admin::FieldsController < Admin::BaseController
  before_action :set_field, except: %i(new create)
  before_action :set_date, only: %i(status)

  def status; end

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

  def edit
    @existing_images = @field.images.map do |image|
      {url: url_for(image), blob_id: image.blob.id}
    end
  end

  def update
    if @field.update field_params
      process_attachments
      flash[:success] = t ".success_message"
      redirect_to status_admin_field_path @field, status: :see_other
    else
      flash.now[:danger] = t ".failure_message"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @field.destroy
      flash[:success] = t ".success_message"
      redirect_to fields_path, status: :see_other
    else
      flash[:danger] = t ".failure_message"
      redirect_to admin_field_path @field, status: :see_other
    end
  end

  private

  def process_attachments
    attach_images if params[:field][:image_storage].present?
    remove_images if params[:field][:image_delete].present?
  end

  def field_params
    params.require(:field).permit(Field::PERMITTED_ATTRIBUTES)
  end

  def set_field
    @field = Field.find_by id: params[:id]
    return if @field.present?

    flash[:danger] = t ".messages.error_field_not_found"
    redirect_to fields_path
  end

  def set_date
    @date = if params[:date].present?
              Date.parse params[:date].to_s
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

  def remove_images
    image_data = JSON.parse params[:field][:image_delete]
    image_data.each do |blob_id|
      image = @field.images.find_by(blob_id:)
      image.purge if image.present?
    end
  end
end
