class GetZoomMeetingService
  def initialize(user:)
    @user = user
    @zoom_meeting = @user.zoom_meeting
  end

  def call
    response = zoom_meeting_get_request
    update_zoom_meeting_password(response)
    response
  end

  private

  def zoom_meeting_get_request
    HTTParty.get(
      "https://api.zoom.us/v2/meetings/#{@zoom_meeting.meeting_id}",
      headers: {
        "Authorization": "Bearer #{@user&.zoom_access_token}",
        "Content-Type": "application/json"
      }
    )
  end

  def update_zoom_meeting_password(response)
    return if response["password"]&.to_s == @zoom_meeting.password

    @zoom_meeting.update(password: response["password"])
  end
end
