class ParticipantJoinedService
  include ZoomWebhookPayloadGettersConcern
  include ZoomWebhookUsernameConcern
  include ZoomWebhookConcern
  include BroadcasterConcern
  include WebhookBroadcasterConcern
  include ZoomWebhookTrackingConcern

  def initialize(params:, user:, meeting:)
    @params = params
    @user = user
    @meeting = meeting
  end

  def call
    set_participant
    @joined_meeting_room = true

    if user_can_be_updated?
      update_user
      track_meeting_event("joined", "meeting")
    elsif participant_can_be_updated?
      broadcast_and_update_participant
      track_meeting_event("joined", "meeting")
    end
  end

  def broadcast_and_update_participant
    set_broadcast_cargo
    update_participant("meeting_room")
    broadcast_updates
  end

  def update_user
    @user.update(last_joined_meeting_at: event_ts_datetime)
  end
end
