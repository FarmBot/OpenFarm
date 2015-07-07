class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  respond_to :json

  before_action :authenticate_from_token!

  rescue_from OpenfarmErrors::NotAuthorized do |exc|
    json = { error: "Not Authorized. #{exc.message}" }
    render json: json, status: 401
  end

  # Convenience methods for serializing models:
  def serialize_model(model, options = {})
    options[:is_collection] = false
    JSONAPI::Serializer.serialize(model, options)
  end

  def serialize_models(models, options = {})
    options[:is_collection] = true
    puts options
    JSONAPI::Serializer.serialize(models, options)
  end

  protected

  def authenticate_from_token!
    request.authorization.present? ? token_auth : authenticate_user!
  end

  def token_auth
    authenticate_or_request_with_http_token do |token, _options|
      user = Token::AuthorizationPolicy.new(token).build
      sign_in user, store: false if user
    end
  end

  def respond_with_mutation(status = :ok, options = {})
    if @outcome.success?
      render json: serialize_model(@outcome.result, options), status: status
    else
      errors = @outcome.errors.message_list.map do |error|
        { 'title': error }
      end
      render json: { errors: errors },
             status: :unprocessable_entity

    end
  end
end
