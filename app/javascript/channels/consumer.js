// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()

export function getConsumerType() {
  if (document.cookie.includes("xyz_signed_in_as_user=true"))
    return "User"
  else if (document.cookie.includes("xyz_participant="))
    return "Participant"
  else if (document.cookie.includes("xyz_guest_token="))
    return "Guest"
  else if (document.cookie.includes("xyz_invited_user_token"))
    return "InvitedUser"
}
