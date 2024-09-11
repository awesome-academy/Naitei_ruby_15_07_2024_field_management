class User::RatingsController < User::BaseController
  before_action :store_user_location, if: :storable_location?
  before_action :authenticate_user!, :check_booking, only: %i(create)
  before_action :find_field
  before_action :find_rating, only: :destroy

  def create
    @rating = current_user.ratings.build rating_params
    @rating.field = @field
    @rating.comment.user = current_user

    if @rating.save
      flash[:success] = t ".create.message.success"
    else
      flash[:danger] = t ".create.message.fail"
    end

    render_turbo_rating
  end

  def destroy
    if @rating.user == current_user
      @rating.destroy
      flash[:success] = t ".destroy.message.success"
    else
      flash[:danger] = t ".destroy.message.fail"
    end
    render_turbo_rating
  end

  private

  def check_booking
    return if current_user.booking_fields.yet_book?(params[:field_id]).present?

    flash[:danger] = t ".not_booking_not_rating"
    redirect_to root_path
  end

  def render_turbo_rating
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reviews_section",
          partial: "user/ratings/review",
          locals: {field: @field}
        )
      end
      format.html{redirect_to field_path(@field)}
    end
  end

  def find_field
    @field = Field.find_by id: params[:field_id]
    return if @field

    flash[:danger] = t ".message.not_found_field"
    redirect_to root_url
  end

  def find_rating
    @rating = @field.ratings.find_by id: params[:id]
    return if @rating

    flash[:danger] = t ".message.not_found_rating"
    redirect_to root_url
  end

  def rating_params
    params.require(:rating).permit Rating::RATING_PARAMS
  end
end
