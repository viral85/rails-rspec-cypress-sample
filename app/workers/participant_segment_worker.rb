class ParticipantSegmentWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: "low"
  sidekiq_retry_in { |_count| 1 }

  def perform(participant_id, event)
    return unless AppConfigurations.segment_enabled?

    ParticipantSegmentService.new(
      participant_id: participant_id,
      event: event
    ).call
  end
end
