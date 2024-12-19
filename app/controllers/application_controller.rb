class ApplicationController < ActionController::API
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :authorized
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter
  # rescue_from StandardError, with: :handle_generic_error

  # global exceptions handlers
  def handle_invalid_record(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_not_found(e)
    render json: { error: "Record not found: #{e.model}" }, status: :not_found
  end

  def handle_missing_parameter(e)
    render json: { error: "Missing parameter: #{e.param}" }, status: :bad_request
  end

  def handle_generic_error(e)
    Rails.logger.error(e.message)
    render json: { error: e.message }, status: :internal_server_error
  end

  # JWT
  def encode_token(payload)
    JWT.encode(payload, ENV.fetch("SECRET_KEY"))
  end

  def decoded_token
    header = request.headers["Authorization"]
    if header
      token = header.split(" ")[1]
      begin
        JWT.decode(token, ENV.fetch("SECRET_KEY"))
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]["user_id"]
      @user = User.find_by(id: user_id)
    end
  end

  def authorized
    unless !!current_user
      render json: { message: "Please log in" }, status: :unauthorized
    end
  end
end
