class ParticipantLeftWaitingRoomService
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

    return unless participant_can_be_updated?

    set_broadcast_cargo
    update_participant("inactive")
    broadcast_updates
    track_meeting_event("left", "waiting")
  end
end
