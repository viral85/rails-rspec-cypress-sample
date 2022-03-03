class ParticipantJoinedWaitingRoomService
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

    @joined_waiting_room = true
    return unless participant_can_be_updated?

    set_broadcast_cargo
    update_participant("waiting_room")
    broadcast_updates
    track_meeting_event("joined", "waiting")
  end
end
