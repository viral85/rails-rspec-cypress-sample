class SegmentWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: "low"
  sidekiq_retry_in { |_count| 1 }

  def perform(user_id, event)
    return unless AppConfigurations.segment_enabled?

    SegmentService.new(user_id: user_id, event: event).call
  end
end
