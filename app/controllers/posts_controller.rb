class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :update, :destroy ]
  before_action :authorize_post_owner!, only: [ :update, :destroy ]

  def index
    @posts = Post.all
    render json: @posts, include: [ "tags", "comments" ]
  end

  def create
    @post = current_user.posts.new(post_params)
    handle_post_tags
    @post.save!
    PostCleanupJob.set(wait: 24.hours).perform_later(@post)
    render json: @post, include: [ "tags", "comments" ], status: :created
  end

  def show
    render json: @post, include: [ "tags", "comments" ]
  end

  def update
    handle_post_tags
    @post.body = params[:body] if params[:body].present?
    @post.title = params[:title] if params[:title].present?
    @post.save!
    render json: @post, include: [ "tags", "comments" ]
  end

  def destroy
    @post.destroy
    head :no_content
  end

  def handle_post_tags
    if params[:tags].present?
      tag_names = params[:tags]
      tags = tag_names.map { |name| Tag.find_or_create_by(name: name.strip) }
      @post.tags = tags
    end
  end

  private
  def post_params
    params.require(:post).permit(:title, :body, :tags)
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_owner!
    if @post.author != current_user
      render json: { message: "You are not authorized to perform this action" },  status: :forbidden
    end
  end
end
