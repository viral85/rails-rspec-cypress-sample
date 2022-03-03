class MeetingEndedService
  include ZoomWebhookPayloadGettersConcern
  include ZoomWebhookConcern

  def initialize(params:, user:, meeting:)
    @params = params
    @user = user
    @meeting = meeting
  end

  def call
    destroy_case_attendances
    end_case
    broadcast_msg
    track_in_segment
  end

  private

  def destroy_case_attendances
    @user&.active_case&.attendances&.each do |attendance|
      participant = attendance.participant
      attendance&.destroy
      if participant.attendances.count.positive?
        participant.update(zoom_status: "waiting_room")
      else
        participant.update(zoom_status: "inactive")
      end
    end
  end

  def end_case
    @user&.active_case&.update(meeting_status: "ended")
  end

  def broadcast_msg
    MeetingBroadcaster.new(user: @user).meeting_ended
  end

  def track_in_segment
    event = {
      "type": "track",
      "title": "Stopped xyz Meeting",
      "properties": { topic: @meeting.topic, meeting_id: @meeting.uuid }
    }
    SegmentWorker.perform_async(@user&.id, event)
  end
end
