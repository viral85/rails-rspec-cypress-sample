module Webhooks
  class ZoomWebhooksController < WebhooksController
    TOKEN = Rails.application.credentials.zoom[:webhook_verificaiton_token]
    before_action :authenticate, only: [:index] if Rails.env.production?
    before_action :validate_request, only: [:index]

    def index
      request = ZoomWebhookRequest.new(
        request: params, event: params["event"],
        event_ts: params["event_ts"], request_valid: true
      )

      ZoomWebhookWorker.perform_async(request&.id) if request.save

      render json: { message: "Request proccessed successfully" }, status: :ok
    end

    def deauth
      DeauthService.new(params: params).call
      head :ok
    end

    private

    def authenticate
      request_token = request.headers["authorization"]
      return if ActiveSupport::SecurityUtils.secure_compare(request_token, TOKEN)

      render json: { message: "HTTP Token: Access denied.\n" }, status: :unauthorized
    end

    def validate_request
      return if valid_request?

      ZoomWebhookRequest.create(request: params, request_valid: false) if params

      render json: {
        message: "The request does not include the proper paramaters."
      }, status: :bad_request
    end

    def valid_request?
      params.present? &&
        params["event"].present? &&
        params["event_ts"].present? &&
        params["event_ts"].is_a?(Integer)
    end
  end
end
