class HostPanelChannel < ApplicationCable::Channel
  def subscribed
    reject and return unless connection.authorized_user?

    stream_from "host_panel:#{client.id}"
  end

  def unsubscribed; end
end
