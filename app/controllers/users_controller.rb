class UsersController < ApplicationController
  skip_before_action :authorized, only: [ :create ]

  def create
    user = User.create!(user_params)
    @token = encode_token(user_id: user.id)
    render json: { user: UserSerializer.new(user), token: @token }, status: :created
  end

  def me
    render json: current_user, status: :ok
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :image)
  end
end
