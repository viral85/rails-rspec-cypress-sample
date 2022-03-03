class IndividualViewOnlyPanelChannel < ApplicationCable::Channel
  def subscribed
    reject and return unless connection.valid_invited_user?

    panel.track_active_invited_user connection.invited_user_token
    panel.broadcast_invited_users_counter_updates

    stream_from "individual_view_only_panel:#{connection.invited_user_token}"
  end

  def unsubscribed
    panel.untrack_active_invited_user connection.invited_user_token
    panel.broadcast_invited_users_counter_updates
  end

  private

  def panel
    connection.invitor_user.panel
  end
end
