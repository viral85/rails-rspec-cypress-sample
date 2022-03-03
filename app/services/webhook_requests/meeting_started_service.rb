class MeetingStartedService
  include ZoomWebhookPayloadGettersConcern
  include ZoomWebhookConcern

  def initialize(params:, user:, meeting:)
    @params = params
    @user = user
    @meeting = meeting
  end

  def call
    broadcast_msg
    track_in_segment
  end

  private

  def broadcast_msg
    MeetingBroadcaster.new(user: @user).meeting_started
  end

  def track_in_segment
    event = {
      "type": "track",
      "title": "Started xyz Meeting",
      "properties": { topic: @meeting.topic, meeting_id: @meeting.uuid }
    }
    SegmentWorker.perform_async(@user&.id, event)
  end
end
