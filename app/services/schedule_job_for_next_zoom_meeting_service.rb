class ScheduleJobForNextZoomMeetingService
  def initialize(user:, zoom_meeting:)
    @user = user
    @zoom_meeting = zoom_meeting
  end

  def call
    create_job_for_next_zoom_meeting
  end

  private

  def create_job_for_next_zoom_meeting
    # Set at 3 AM CT
    if @zoom_meeting.meeting_worker_id.nil? ||
       Sidekiq::ScheduledSet.new.find_job(@zoom_meeting.meeting_worker_id).nil?
      worker_id = NewZoomMeetingWorker.perform_at(
        @zoom_meeting.meeting_end_date(@zoom_meeting.created_at), @user.id
      )
      @zoom_meeting.update(meeting_worker_id: worker_id)
    end
  end
end
