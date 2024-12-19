class CommentsController < ApplicationController
  before_action :set_post, only: [ :create, :update, :destroy ]
  before_action :set_comment, only: [ :update, :destroy ]
  before_action :authorize_comment_owner!, only: [ :update, :destroy ]

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    @comment.save!
    render json: @comment, status: :created
  end

  def update
    @comment.update!(comment_params)
    render json: @comment, status: :accepted
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private
  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def authorize_comment_owner!
    if @comment.user != current_user
      render json: { message: "You are not authorized to perform this action" },  status: :forbidden
    end
  end
end
