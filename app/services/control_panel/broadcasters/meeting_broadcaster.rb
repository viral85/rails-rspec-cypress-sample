class MeetingBroadcaster
  def initialize(user:)
    @user = user
  end

  def meeting_started
    ActionCable.server.broadcast(
      "common_panel_changes:#{@user&.id}",
      webhook_signal: {
        type: "meeting_started"
      }
    )
  end

  def meeting_ended
    ActionCable.server.broadcast(
      "common_panel_changes:#{@user&.id}",
      webhook_signal: {
        type: "meeting_ended"
      }
    )
  end
end
