class ZoomWebhookService
  include ZoomWebhookPayloadGettersConcern
  include ZoomWebhookConcern

  def initialize(request_id:)
    @params = ZoomWebhookRequest.find_by(id: request_id)&.request
    @error = nil
    set_user
    set_zoom_meeting
  end

  def call
    direct_request
  end

  private

  def direct_request # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    event = @params["event"]

    return unless can_process_webhook?

    case event
    when "meeting.started"
      MeetingStartedService.new(**webhook_args).call
    when "meeting.ended"
      MeetingEndedService.new(**webhook_args).call
    when "meeting.participant_joined_waiting_room"
      ParticipantJoinedWaitingRoomService.new(**webhook_args).call
    when "meeting.participant_left_waiting_room"
      ParticipantLeftWaitingRoomService.new(**webhook_args).call
    when "meeting.participant_admitted"
      ParticipantAdmittedService.new(**webhook_args).call
    when "meeting.participant_joined"
      ParticipantJoinedService.new(**webhook_args).call
    when "meeting.participant_put_in_waiting_room"
      ParticipantPutInWaitingRoomService.new(**webhook_args).call
    when "meeting.participant_left"
      ParticipantLeftService.new(**webhook_args).call
    when "meeting.updated"
      ZoomMeetingUpdateService.new(**webhook_args).call
    end
  end

  def webhook_args
    {
      params: @params,
      user: @user,
      meeting: @meeting
    }
  end

  def set_user
    @identity = Identity.find_by(uid: payload_zoom_host_id)
    @user = @identity&.user
  end

  def set_zoom_meeting
    @meeting = correct_meeting? ? @user&.zoom_meeting : nil
  end

  def correct_meeting?
    @user&.zoom_meeting&.meeting_id == payload_meeting_id&.to_s
  end

  def can_process_webhook?
    @user.present? && @meeting.present?
  end
end
