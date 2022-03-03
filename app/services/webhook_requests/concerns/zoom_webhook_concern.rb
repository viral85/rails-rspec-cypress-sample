module ZoomWebhookConcern
  extend ActiveSupport::Concern

  private

  def set_participant
    @participant = set_participant_by_email || set_participant_by_phone_number || create_participant
  end

  def set_participant_by_email
    return nil if payload_email.blank?

    @user&.participants&.find_by(email: payload_email)
  end

  def event_ts_datetime
    ts_in_seconds = @params["event_ts"] / 1000
    Time.at(ts_in_seconds).utc.to_datetime
  end

  def create_participant
    return if @participant_left_meeting || participant_is_host? || participant_is_cohost?

    @participant = Participant.create(
      first_name: extract_first_name, last_name: extract_last_name,
      role: extract_role, zoom_username: payload_username,
      email: payload_email, user: @user,
      token: extract_token, zoom_status: "inactive"
    )

    @participant.update(phone: payload_username) if username_is_phone_number?
    @participant
  end

  def set_participant_by_phone_number
    return nil unless username_is_phone_number?

    @participant = @user.participants.find_by(phone: payload_username)
    @participant
  end

  def username_is_phone_number?
    /\A(?:\+?(\d|\*){1,3}\s*-?)?\(?(?:(\d|\*){3})?\)?[- ]?(\d|\*){3}[- ]?(\d|\*){4}\z/
      .match?(payload_username)
  end

  def participant_can_be_updated?
    @participant.present? && !participant_is_host? && !participant_is_cohost? && timestamp_in_order?
  end

  def user_can_be_updated?
    participant_is_host? && last_joined_meeting_at_in_order?
  end

  def participant_is_host?
    payload_participant_id == payload_zoom_host_id
  end

  def participant_is_cohost?
    payload_username == "xyz.io"
  end

  def timestamp_in_order?
    @participant.event_ts.nil? || @participant.event_ts < @params["event_ts"]
  end

  def last_joined_meeting_at_in_order?
    @user.last_joined_meeting_at.nil? || @user.last_joined_meeting_at.to_i < @params["event_ts"]
  end

  def update_participant(zoom_status)
    initialize_updated_participant(zoom_status)
    update_participant_name_and_role
    update_zoom_username
    update_joined_times
    @participant.save
  end

  def initialize_updated_participant(zoom_status)
    @participant.assign_attributes(
      zoom_user_id: payload_zoom_user_id, event_body: @params&.to_enum&.to_h,
      event_ts: @params["event_ts"], zoom_status: zoom_status
    )
  end

  def update_participant_name_and_role
    # Do not upate name and role for phone numbers
    return if username_is_phone_number?

    @participant.first_name = extract_first_name if name_changed?
    @participant.last_name = extract_last_name if name_changed?
    @participant.role = extract_role if role_changed?
  end

  def update_zoom_username
    @participant.zoom_username = payload_username if initial_joined_waiting_at
  end

  def update_joined_times
    @participant.entered_waiting_room_at = initial_joined_waiting_at if initial_joined_waiting_at
    @participant.last_joined_waiting_at = last_joined_waiting_at if last_joined_waiting_at
    @participant.last_joined_meeting_at = joined_meeting_at if joined_meeting_at
  end

  def initial_joined_waiting_at
    return unless @joined_waiting_room || @participant.entered_waiting_room_at.blank?

    event_ts_datetime
  end

  def last_joined_waiting_at
    return unless @put_in_waiting_room || @joined_waiting_room ||
                  @participant.entered_waiting_room_at.blank?

    event_ts_datetime
  end

  def joined_meeting_at
    return unless @joined_meeting_room

    event_ts_datetime
  end
end
