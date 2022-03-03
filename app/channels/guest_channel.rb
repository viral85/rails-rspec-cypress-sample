class GuestChannel < ApplicationCable::Channel
  include ::ActionController::Cookies
  def subscribed
    stream_from "guest:#{connection.guest_token}" if connection.guest?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
