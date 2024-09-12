class User::CommentsController < User::BaseController
  before_action :store_user_location, if: :storable_location?
  before_action :authenticate_user!, :find_parent_comment, :find_rating,
                only: :create

  def create
    @comment = Comment.new comment_params
    @comment.rating = @rating
    @comment.parent = @parent_comment
    @comment.user = current_user

    if @comment.save
      flash[:success] = t ".create.message.success"
      redirect_to field_path @rating.field
    else
      flash[:error] = t ".fail"
      redirect_to root_path
    end
  end

  private

  def find_rating
    @rating = Rating.find_by id: params[:rating_id]
    return unless @rating.nil?

    flash[:error] = t ".create.message.fail"
    redirect_to root_path
  end

  def find_parent_comment
    return unless params[:parent_id]

    @parent_comment = Comment.find_by id: params[:parent_id]
    return unless @parent_comment.nil?

    flash[:error] = t ".create.message.fail"
    redirect_to root_path
  end

  def comment_params
    params.require(:comment).permit Comment::COMMENT_PARAMS
  end
end
