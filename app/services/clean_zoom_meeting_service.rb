class CleanZoomMeetingService
  def initialize(user:)
    @user = user
    @zoom_meeting = @user&.zoom_meeting
  end

  def call
    delete_participants
    delete_previous_job
    delete_xyz_meeting
  end

  private

  def delete_participants
    @user.participants.each(&:destroy)
  end

  def delete_previous_job
    job = Sidekiq::ScheduledSet.new.find_job(@zoom_meeting&.meeting_worker_id)
    job&.delete
  end

  def delete_xyz_meeting
    @zoom_meeting&.destroy
  end

  def zoom_meeting_delete_request
    HTTParty.delete(
      "https://api.zoom.us/v2/meetings/#{@zoom_meeting.meeting_id}",
      headers: {
        "Authorization": "Bearer #{@user&.zoom_access_token}",
        "Content-Type": "application/json"
      }
    )
  end
end
