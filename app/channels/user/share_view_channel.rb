class ShareViewChannel < ApplicationCable::Channel
  def subscribed
    reject and return unless connection.valid_invited_user?

    stream_from "share_view:#{connection.invitor_token}"
  end

  def unsubscribed; end
end
