namespace :zoom_meetings do
  desc "Update ZoomMeeting"

  task create_next_meeting_jobs: :environment do
    ZoomMeeting.where(meeting_worker_id: nil).find_each(batch_size: 1) do |meeting|
      ScheduleJobForNextZoomMeetingService.new(user: meeting.user, zoom_meeting: meeting).call
    rescue ActiveRecord::RecordNotFound
      p "Meeting id #{meeting.id} fail"
    rescue StandardError
      p "Meeting id #{meeting.id} fail"
    end
  end
end
