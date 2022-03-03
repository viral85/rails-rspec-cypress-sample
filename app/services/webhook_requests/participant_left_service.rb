class ParticipantLeftService
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
    @participant_left_meeting = true
  end

  def call
    set_participant

    if user_can_be_updated?
      track_meeting_event("left", "meeting")
    elsif participant_can_be_updated?
      broadcast_and_update_participant
      track_meeting_event("left", "meeting")
    end
  end

  def broadcast_and_update_participant
    set_broadcast_cargo
    update_participant("inactive")
    broadcast_updates
  end
end
