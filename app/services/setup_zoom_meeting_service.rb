class SetupZoomMeetingService
  def initialize(user:)
    @user = user
    @zoom_meeting = @user&.zoom_meeting
  end

  def call(clean: false)
    if clean
      clean_and_create_meeting
    elsif @user.zoom_meeting.blank?
      create_zoom_meeting
    else
      @user.zoom_meeting.update_from_zoom
      clean_and_create_meeting unless @user.zoom_meeting.current_zoom_meeting_exists?
    end
  end

  private

  def clean_and_create_meeting
    CleanZoomMeetingService.new(user: @user).call
    create_zoom_meeting
  end

  def create_zoom_meeting
    @zoom_meeting = ZoomMeeting.new(user: @user)
    response = zoom_meeting_post_request
    @zoom_meeting.update_from(response)
    ScheduleJobForNextZoomMeetingService.new(user: @user, zoom_meeting: @zoom_meeting).call
  end

  def zoom_meeting_post_request
    HTTParty.post(
      "https://api.zoom.us/v2/users/#{@user&.zoom_identity&.uid}/meetings",
      headers: {
        "Authorization": "Bearer #{@user&.zoom_access_token}",
        "Content-Type": "application/json"
      },
      body: setup_meeting.to_json
    )
  end

  def setup_meeting
    start_time = Time.zone.now.beginning_of_day
    {
      topic: meeting_title,
      type: ZoomMeeting.recurring_meeting_with_fixed_time_type,
      settings: ZoomMeeting.meeting_settings,
      recurrence: @zoom_meeting.recurrence_setting(start_time),
      start_time: start_time.strftime("%Y-%m-%dT%H:%M:%S"),
      duration: 1440 # meeting duration(minutes)
    }
  end

  def meeting_title
    title = @user.to_s
    title += " (Dev)" if Rails.env.development?
    title
  end
end
