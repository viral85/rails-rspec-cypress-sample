class ZoomMeeting < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :meeting_id, :uuid, presence: true

  # Callbacks
  before_update :track_in_segment, if: :will_save_change_to_topic?

  serialize :interpreters

  def fetch_zoom_meeting
    response = GetZoomMeetingService.new(user: user).call
    update(last_response: response)
    response
  end

  def update_from_zoom
    response = fetch_zoom_meeting if response.blank?
    return false unless exist_in_zoom?

    update_from(response)
  end

  def update_from(response)
    interpreters =
      response["settings"]&.fetch("language_interpretation", nil)&.to_h || interpreters
    expires = 2.hours.from_now

    update!(meeting_id: response["id"], uuid: response["uuid"], topic: response["topic"],
            join_url: response["join_url"], password: response["password"],
            meeting_type: response["type"], status: response["status"],
            start_url: response["start_url"], start_url_expires: expires,
            registration_url: response["registration_url"],
            interpreters: interpreters, last_response: response)
  end

  def update_meeting_type_in_zoom
    start_time = Time.zone.now.beginning_of_day
    meeting_type_params = {
      type: ZoomMeeting.recurring_meeting_with_fixed_time_type,
      settings: ZoomMeeting.meeting_settings,
      recurrence: recurrence_setting(start_time),
      start_time: start_time.strftime("%Y-%m-%dT%H:%M:%S")
    }
    EditZoomMeetingService.new(user: user, params: meeting_type_params).call
  end

  def recurrence_setting(start_time)
    {
      type: 1, # Daily Meeting
      repeat_interval: 1, # value 1 means recurs every day
      end_date_time: meeting_end_date(start_time).strftime("%Y-%m-%dT%H:%M:%SZ")
    }
  end

  def meeting_end_date(meeting_start_date)
    # 30 days after start date at 3 AM CT
    meeting_start_date.beginning_of_day + 30.days + 8.hours
  end

  def recurring_with_fixed_time?
    meeting_type == 8
  end

  def registration_enabled?
    registration_url.present? && valid_occurrences?
  end

  def valid_occurrences?
    last_response.present? &&
      last_response["occurrences"].present? &&
      last_response["occurrences"].is_a?(Array)
  end

  def exist_in_zoom?
    last_response["id"]&.to_s == meeting_id
  end

  def not_ended?
    end_date = last_response["recurrence"]&.fetch("end_date_time", nil)&.to_date
    end_date&.today? || end_date&.future?
  end

  def ended?
    !not_ended?
  end

  def current_zoom_meeting_exists?
    exist_in_zoom? && not_ended?
  end

  def track_in_segment
    event = {
      "type": "track",
      "title": "Updated Meeting Title",
      "properties": { old_title: topic_was, new_title: topic }
    }
    SegmentWorker.perform_async(user.id, event)
  end

  def start_zoom_button_available?
    status != "started" && start_url_valid?
  end

  def start_url_valid?
    start_url.present? && start_url_expires > Time.zone.now
  end

  def self.recurring_meeting_with_fixed_time_type
    8
  end

  def self.meeting_settings
    {
      host_video: false, participant_video: false, mute_upon_entry: true,
      approval_type: 0, # Automatically approve
      registration_type: 2, # Attendees need to register for each occurrence to attend.
      audio: "both", close_registration: true, waiting_room: true, allow_multiple_devices: false,
      registrants_email_notification: false
    }
  end

  def meets_prerequisites?
    !user&.zoom_basic_plan? && recurring_with_fixed_time? && registration_enabled?
  end
end
