class ParticipantSegmentService
  def initialize(participant_id:, event:)
    @participant = Participant.find(participant_id)
    @analytics_user = @participant&.analytics_user
    @user = @participant.user
    @event = event
  end

  def call
    case @event["type"]
    when "identify"
      identify
    when "track"
      track_event
    else
      false
    end
  end

  private

  def identify
    # track as same user in Segment to reduce monthly active users charge
    # tracking participants as an event but using it as an entity in the analytics DB
    Analytics.track(
      anonymous_id: "8928faec-78a7-4d9c-8d38-7f3fa4653cc6",
      event: "Participants", integrations: { All: false, "Data Warehouse": true },
      properties: {
        id: @analytics_user&.id, first_name: @participant.first_name, locale: @participant.locale,
        last_name: @participant.last_name, role: @participant&.role, phone: @participant.phone,
        user_id: @user.analytics_user.id, organization_id: @user.organization_id,
        registered_at: Time.now.utc
      }
    )
  end

  def track_event
    # track as same user in Segment to reduce monthly active users charge
    Analytics.track(
      anonymous_id: "8928faec-78a7-4d9c-8d38-7f3fa4653cc6",
      event: @event["title"], integrations: { All: false, "Data Warehouse": true },
      properties: @event["properties"]
    )
  end
end
