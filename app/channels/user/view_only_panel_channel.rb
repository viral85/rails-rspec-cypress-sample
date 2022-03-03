class ViewOnlyPanelChannel < ApplicationCable::Channel
  def subscribed
    reject and return unless connection.valid_invited_user?

    stream_from "view_only_panel:#{connection.invitor_token}"
  end

  def unsubscribed; end
end
