class CleanupParticipantsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: "low"

  def perform
    Participant.inactive.destroy_all
  end
end
