class ZoomWebhookWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: "critical"
  sidekiq_retry_in { |_count| 1 }

  def perform(request_id)
    ZoomWebhookService.new(request_id: request_id).call
  end
end
