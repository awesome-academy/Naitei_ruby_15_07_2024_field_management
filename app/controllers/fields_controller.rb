class FieldsController < ApplicationController
  def index
    @fields = Field.with_ave_rate

    filter
    @pagy, @fields = pagy @fields, limit: Settings.field_in_field_list
  end

  def show
    @field = Field.find_by id: params[:id]

    if @field.nil?
      flash[:danger] = t ".field_not_found"
      redirect_to fields_path
    else
      @average_rating = @field.ratings.average(:rating).to_f
      @images = @field.images

      @pagy, @images = pagy @images, limit: Settings.image_field_in_field_detail
    end
  end

  private

  def filter
    @fields = @fields
              .filter_by_name(params[:name])
              .filter_by_grass(params[:grass])
              .filter_by_capacity(params[:capacity])
              .sort_by_price(params[:price])
  end
end
