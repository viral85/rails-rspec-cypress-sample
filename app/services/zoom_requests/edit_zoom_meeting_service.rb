class EditZoomMeetingService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    update_topic_patch_request
  end

  private

  def update_topic_patch_request
    HTTParty.patch(
      "https://api.zoom.us/v2/meetings/#{@user&.zoom_meeting&.meeting_id}",
      headers: {
        "Authorization": "Bearer #{@user&.zoom_access_token}",
        "Content-Type": "application/json"
      },
      body: @params.to_json
    )
  end
end
