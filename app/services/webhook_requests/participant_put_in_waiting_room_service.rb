class ParticipantPutInWaitingRoomService
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

    @put_in_waiting_room = true

    if user_can_be_updated?
      track_meeting_event("left", "meeting")
      track_meeting_event("joined", "waiting")
    elsif participant_can_be_updated?
      broadcast_and_update_participant
      track_meeting_event("left", "meeting")
      track_meeting_event("joined", "waiting")
    end
  end

  def broadcast_and_update_participant
    set_broadcast_cargo
    update_participant("waiting_room")
    broadcast_updates
  end
end
