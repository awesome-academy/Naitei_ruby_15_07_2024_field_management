class Api::V1::RatingsController < ApplicationController
  before_action :set_field

  def index
    @ratings = @field.ratings
    render json: @ratings, each_serializer: RatingSerializer,
           current_user: @current_user
  end

  private

  def set_field
    @field = Field.find_by id: params[:field_id]
    return if @field

    render json: {error: I18n.t("api.v1.field.not_found")}, status: :not_found
  end
end
