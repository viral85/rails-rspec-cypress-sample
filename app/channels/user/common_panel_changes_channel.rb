class CommonPanelChangesChannel < ApplicationCable::Channel
  def subscribed
    reject and return unless connection.authorized_user? || connection.valid_invited_user?

    if connection.authorized_user?
      stream_from "common_panel_changes:#{client.id}"
    elsif connection.valid_invited_user?
      stream_from "common_panel_changes:#{connection.invitor_user.id}"
    end
  end

  def unsubscribed; end
end
