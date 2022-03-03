class ParticipantAdmittedService
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

    if username_is_phone_number? && participant_can_be_updated?
      @joined_meeting_room = true
      broadcast_and_update_participant

      track_meeting_event("left", "waiting")
      track_meeting_event("joined", "meeting")
    elsif participant_can_be_updated?
      track_meeting_event("left", "waiting")
    end
  end

  def broadcast_and_update_participant
    set_broadcast_cargo
    update_participant("meeting_room")
    broadcast_updates
  end
end
