class Api::V1::User::RatingsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :find_field
  before_action :find_rating, only: :destroy

  def index
    @q = Rating.ransack(params[:q])
    @ratings = @q.result.includes(:field)
    @pagy, @ratings = pagy @ratings,
                           limit: Settings.user.booking_fields_pagy
    render json: {
      ratings: @ratings.map{|rate| RatingSerializer.new(rate)}
    }, status: :ok
  end

  def create
    @rating = Rating.new rating_params
    @rating.user = User.last
    @rating.field = @field
    @rating.comment.user = User.last

    if @rating.save
      render json: {
               message: I18n.t("user.ratings.message.success"),
               rating: RatingSerializer.new(@rating)
             },
             status: :created
    else
      render json: {
               message: I18n.t("user.ratings.message.fail"),
               errors: @rating.errors.full_messages
             },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @rating.destroy!
      render json: {
               message: I18n.t("api.v1.user.ratings.destroy_success")
             },
             status: :ok
    else
      render json: {
               message: I18n.t("api.v1.user.ratings.destroy_fail")
             },
             status: :unprocessable_entity
    end
  end

  private

  def check_booking
    return if current_user.booking_fields.yet_book?(params[:field_id]).present?

    render json: {
             message: I18n.t("api.v1.user.ratings.not_booking_not_rating")
           },
           status: :forbidden
  end

  def find_field
    @field = Field.find_by(id: params[:field_id])
    return if @field

    render json: {
             message: I18n.t("api.v1.user.ratings.field_not_found")
           },
           status: :not_found
  end

  def find_rating
    @rating = @field.ratings.find_by(id: params[:id])
    return if @rating

    render json: {
             message: I18n.t("api.v1.user.ratings.rating_not_found")
           },
           status: :not_found
  end

  def rating_params
    params.require(:rating).permit Rating::RATING_PARAMS
  end
end
