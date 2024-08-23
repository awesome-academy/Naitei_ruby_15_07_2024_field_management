class User::CommentsController < ApplicationController
  before_action :logged_in, :login_as_user, :get_parent_comment, :get_rating,
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

  def get_rating
    @rating = Rating.find_by id: params[:rating_id]
    return unless @rating.nil?

    flash[:error] = t ".create.message.fail"
    redirect_to root_path
  end

  def get_parent_comment
    return unless params[:parent_id]

    @parent_comment = Comment.find_by id: params[:parent_id]
    return unless @parent_comment.nil?

    flash[:error] = t ".create.message.fail"
    redirect_to root_path
  end

  def comment_params
    params.require(:comment).permit Comment::COMMENT_PARAMS
  end

  def logged_in
    return if logged_in?

    store_location
    flash[:danger] = t ".please_log_in"
    redirect_to signin_url
  end

  def login_as_user
    return if current_user.user?

    flash[:danger] = t ".you_are_not_user"
    redirect_to root_path
  end
end
