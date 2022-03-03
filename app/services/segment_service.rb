class SegmentService
  def initialize(user_id:, event:)
    @user = User.find(user_id)
    @analytics_user = @user&.analytics_user
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
    Analytics.identify(
      user_id: @analytics_user&.id,
      traits: {
        first_name: @user.first_name, last_name: @user.last_name,
        email: @user&.email, zoom_plan: @user.zoom_plan,
        signed_up: @user&.zoom_identity&.created_at,
        organization_id: @user&.organization&.id, reg_room_url: @user.registration_room_url
      }
    )

    group_user
  end

  def group_user
    Analytics.group(
      user_id: @analytics_user&.id,
      group_id: @user&.organization&.id,
      traits: {
        name: @user&.organization&.name
      }
    )
  end

  def track_event
    Analytics.track(
      user_id: @analytics_user&.id,
      event: @event["title"],
      properties: @event["properties"]
    )
  end
end
