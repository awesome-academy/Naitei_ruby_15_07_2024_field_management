class User::CommentsController < ApplicationController
  before_action :get_parent_comment, only: :create
  before_action :get_rating, only: :create

  def create
    @comment = Comment.new comment_params
    @comment.rating = @rating
    @comment.parent = @parent_comment

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
end
