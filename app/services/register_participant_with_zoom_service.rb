class RegisterParticipantWithZoomService
  def initialize(user:, participant:)
    @user = user
    @participant = participant
    @zoom_meeting = @user.zoom_meeting
  end

  def call
    register_participant_with_zoom
  end

  private

  def register_participant_with_zoom
    response = registrants_post_request
    error_messege = "Participant was not able to register. meeting.id = #{@zoom_meeting.meeting_id}"
    raise CreateRegistrantsError.new(error_messege, response: response) unless response.created?

    response
  end

  def registrants_post_request
    HTTParty.post(
      "https://api.zoom.us/v2/meetings/#{@zoom_meeting.meeting_id}/registrants",
      headers: {
        "Authorization": "Bearer #{@user&.zoom_access_token}",
        "Content-Type": "application/json"
      },
      body: request_body.to_json
    )
  end

  def request_body
    {
      first_name: @participant.first_name.truncate(60, separator: "..."),
      last_name: "#{@participant.last_name} - #{@participant.role}".truncate(60, separator: "..."),
      email: @participant.email
    }
  end
end
