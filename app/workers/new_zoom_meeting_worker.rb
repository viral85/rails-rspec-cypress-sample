class NewZoomMeetingWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: "low"
  sidekiq_retry_in { |_count| 1 }

  def perform(user_id)
    @user = User.find(user_id)
    SetupZoomMeetingService.new(user: @user).call(clean: true)
  end
end
