module ZoomWebhookTrackingConcern
  extend ActiveSupport::Concern

  private

  def track_meeting_event(action, room)
    return unless @participant || @user

    event = define_event

    if participant_is_host?
      event["properties"] = user_properties(action, room)
      SegmentWorker.perform_async(@user&.id, event)
    else
      event["properties"] = participant_properties(action, room)
      ParticipantSegmentWorker.perform_async(@participant&.id, event)
    end
  end

  def define_event
    {
      "type": "track",
      "title": "Meeting Events"
    }
  end

  def user_properties(action, room)
    # TODO: Modify when we have co-host functionality
    role = participant_is_host? ? "Host" : "Co-host"
    duration = user_duration(action, room)

    {
      user_id: @user&.analytics_user&.id, zoom_role: role, action: action,
      room: room, meeting_topic: @user&.zoom_meeting&.topic,
      zoom_meeting_id: payload_meeting_id, zoom_user_id: payload_zoom_user_id,
      organization_id: @user&.organization_id, duration_seconds: duration,
      duration_minutes: duration_minutes(duration), event_ts: @params["event_ts"],
      event_ts_datetime: event_ts_datetime
    }
  end

  def participant_properties(action, room)
    duration = participant_duration(action, room)

    {
      participant_id: @participant.analytics_user.id,
      user_id: @user.analytics_user.id, zoom_role: "Participant", action: action,
      room: room, meeting_topic: @user&.zoom_meeting&.topic,
      zoom_meeting_id: payload_meeting_id, zoom_user_id: payload_zoom_user_id,
      organization_id: @user&.organization_id, duration_seconds: duration,
      duration_minutes: duration_minutes(duration), event_ts: @params["event_ts"],
      event_ts_datetime: event_ts_datetime
    }
  end

  def user_duration(action, room)
    return unless action == "left" && room == "meeting"

    time_ago_in_seconds(@user.last_joined_meeting_at)
  end

  def participant_duration(action, room)
    if action == "left" && room == "waiting"
      time_ago_in_seconds(@participant.last_joined_waiting_at)
    elsif action == "left" && room == "meeting"
      time_ago_in_seconds(@participant.last_joined_meeting_at)
    end
  end

  def time_ago_in_seconds(end_time)
    return unless end_time

    (event_ts_datetime.utc.to_i - end_time.utc.to_i).abs.round
  end

  def duration_minutes(duration)
    return unless duration

    (duration.to_f / 60).round(2)
  end
end
